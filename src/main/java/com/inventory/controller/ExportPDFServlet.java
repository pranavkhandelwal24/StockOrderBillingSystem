package com.inventory.controller;

import com.inventory.utils.DBUtil;
import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;

public class ExportPDFServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int orderId = Integer.parseInt(request.getParameter("orderId"));

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=invoice_" + orderId + ".pdf");

        try {
            Connection conn = DBUtil.getConnection();

            PreparedStatement orderStmt = conn.prepareStatement(
                "SELECT o.order_date, o.total_amount, c.name, c.email, c.phone, c.address " +
                "FROM orders o JOIN customers c ON o.customer_id = c.customer_id WHERE o.order_id = ?");
            orderStmt.setInt(1, orderId);
            ResultSet orderRs = orderStmt.executeQuery();

            PreparedStatement itemsStmt = conn.prepareStatement(
                "SELECT s.item_name, oi.quantity, oi.price_per_item " +
                "FROM order_items oi JOIN stock s ON oi.stock_id = s.stock_id WHERE oi.order_id = ?");
            itemsStmt.setInt(1, orderId);
            ResultSet itemsRs = itemsStmt.executeQuery();

            Document doc = new Document();
            PdfWriter.getInstance(doc, response.getOutputStream());
            doc.open();

            Font bold = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12);

            doc.add(new Paragraph("🧾 Invoice", bold));
            doc.add(new Paragraph("Order ID: " + orderId));
            doc.add(new Paragraph(" "));

            if (orderRs.next()) {
                doc.add(new Paragraph("Customer: " + orderRs.getString("name")));
                doc.add(new Paragraph("Email: " + orderRs.getString("email")));
                doc.add(new Paragraph("Phone: " + orderRs.getString("phone")));
                doc.add(new Paragraph("Address: " + orderRs.getString("address")));
                doc.add(new Paragraph("Date: " + orderRs.getTimestamp("order_date")));
                doc.add(new Paragraph(" "));
            }

            PdfPTable table = new PdfPTable(4);
            table.setWidthPercentage(100);
            table.setSpacingBefore(10);
            table.addCell("Item");
            table.addCell("Qty");
            table.addCell("Rate");
            table.addCell("Total");

            double grandTotal = 0;
            while (itemsRs.next()) {
                String item = itemsRs.getString("item_name");
                int qty = itemsRs.getInt("quantity");
                double price = itemsRs.getDouble("price_per_item");
                double total = qty * price;
                grandTotal += total;

                table.addCell(item);
                table.addCell(String.valueOf(qty));
                table.addCell("₹ " + price);
                table.addCell("₹ " + total);
            }

            doc.add(table);

            doc.add(new Paragraph(" "));
            doc.add(new Paragraph("Total Amount: ₹ " + grandTotal, bold));

            doc.close();

        } catch (Exception e) {
            throw new ServletException("PDF generation failed", e);
        }
    }
}
