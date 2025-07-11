package com.inventory.controller;

import com.inventory.utils.DBUtil;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import java.text.DecimalFormat;

@WebServlet("/exportExcel")
public class ExportExcelServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int orderId = Integer.parseInt(request.getParameter("orderId"));
        DecimalFormat df = new DecimalFormat("0.00");
        double cgstRate = 0.09;
        double sgstRate = 0.09;

        try (Connection conn = DBUtil.getConnection()) {
            // Fetch Order
            PreparedStatement orderStmt = conn.prepareStatement(
                    "SELECT o.order_id, o.order_date, o.total_amount, c.name, c.email, c.phone, c.address " +
                    "FROM orders o JOIN customers c ON o.customer_id = c.customer_id WHERE o.order_id = ?");
            orderStmt.setInt(1, orderId);
            ResultSet orderRs = orderStmt.executeQuery();

            // Fetch Items
            PreparedStatement itemStmt = conn.prepareStatement(
                    "SELECT s.item_name, oi.quantity, oi.price_per_item " +
                    "FROM order_items oi JOIN stock s ON oi.stock_id = s.stock_id WHERE oi.order_id = ?");
            itemStmt.setInt(1, orderId);
            ResultSet itemRs = itemStmt.executeQuery();

            if (!orderRs.next()) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Order not found");
                return;
            }

            // Start Excel
            Workbook workbook = new XSSFWorkbook();
            Sheet sheet = workbook.createSheet("Invoice");

            int rowNum = 0;

            // Header
            Row headerRow = sheet.createRow(rowNum++);
            headerRow.createCell(0).setCellValue("Order Invoice");

            // Customer Info
            rowNum++;
            sheet.createRow(rowNum++).createCell(0).setCellValue("Customer Name: " + orderRs.getString("name"));
            sheet.createRow(rowNum++).createCell(0).setCellValue("Email: " + orderRs.getString("email"));
            sheet.createRow(rowNum++).createCell(0).setCellValue("Phone: " + orderRs.getString("phone"));
            sheet.createRow(rowNum++).createCell(0).setCellValue("Address: " + orderRs.getString("address"));
            sheet.createRow(rowNum++).createCell(0).setCellValue("Order ID: " + orderId);
            sheet.createRow(rowNum++).createCell(0).setCellValue("Order Date: " + orderRs.getTimestamp("order_date"));

            rowNum++;

            // Table Header
            Row tableHeader = sheet.createRow(rowNum++);
            tableHeader.createCell(0).setCellValue("#");
            tableHeader.createCell(1).setCellValue("Item");
            tableHeader.createCell(2).setCellValue("Qty");
            tableHeader.createCell(3).setCellValue("Price/Unit");
            tableHeader.createCell(4).setCellValue("Total");

            int count = 1;
            double subtotal = 0;

            // Item Rows
            while (itemRs.next()) {
                int qty = itemRs.getInt("quantity");
                double price = itemRs.getDouble("price_per_item");
                double total = qty * price;
                subtotal += total;

                Row row = sheet.createRow(rowNum++);
                row.createCell(0).setCellValue(count++);
                row.createCell(1).setCellValue(itemRs.getString("item_name"));
                row.createCell(2).setCellValue(qty);
                row.createCell(3).setCellValue(price);
                row.createCell(4).setCellValue(total);
            }

            // Totals
            double cgst = subtotal * cgstRate;
            double sgst = subtotal * sgstRate;
            double grandTotal = subtotal + cgst + sgst;

            rowNum++;
            sheet.createRow(rowNum++).createCell(3).setCellValue("Subtotal:");
            sheet.getRow(rowNum - 1).createCell(4).setCellValue(df.format(subtotal));

            sheet.createRow(rowNum++).createCell(3).setCellValue("CGST (9%):");
            sheet.getRow(rowNum - 1).createCell(4).setCellValue(df.format(cgst));

            sheet.createRow(rowNum++).createCell(3).setCellValue("SGST (9%):");
            sheet.getRow(rowNum - 1).createCell(4).setCellValue(df.format(sgst));

            sheet.createRow(rowNum++).createCell(3).setCellValue("Grand Total:");
            sheet.getRow(rowNum - 1).createCell(4).setCellValue(df.format(grandTotal));

            // Response
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader("Content-Disposition", "attachment; filename=order_" + orderId + ".xlsx");
            workbook.write(response.getOutputStream());
            workbook.close();

        } catch (Exception e) {
            throw new ServletException("Excel export failed", e);
        }
    }
}
