package com.inventory.controller;

import com.inventory.utils.DBUtil;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;

@WebServlet("/GenrateBillServlet")
public class GenrateBillServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int orderId = Integer.parseInt(request.getParameter("orderId"));

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        try (Connection conn = DBUtil.getConnection()) {
            // Fetch order and customer details
            PreparedStatement orderStmt = conn.prepareStatement(
                "SELECT o.order_date, o.total_amount, c.name, c.email, c.phone, c.address " +
                "FROM orders o JOIN customers c ON o.customer_id = c.customer_id WHERE o.order_id = ?"
            );
            orderStmt.setInt(1, orderId);
            ResultSet orderRs = orderStmt.executeQuery();

            // Fetch order items
            PreparedStatement itemsStmt = conn.prepareStatement(
                "SELECT s.item_name, oi.quantity, oi.price_per_item " +
                "FROM order_items oi JOIN stock s ON oi.stock_id = s.stock_id WHERE oi.order_id = ?"
            );
            itemsStmt.setInt(1, orderId);
            ResultSet itemsRs = itemsStmt.executeQuery();

            // HTML response
            out.println("<html><head><title>Invoice - Order #" + orderId + "</title>");
            out.println("<style>");
            out.println("body{font-family:Arial,sans-serif;padding:20px;}");
            out.println("table{width:100%;border-collapse:collapse;margin-top:20px;}");
            out.println("th, td{border:1px solid #ccc;padding:8px;text-align:left;}");
            out.println("th{background:#f2f2f2;}");
            out.println("</style></head><body>");

            out.println("<h2>🧾 Invoice</h2>");
            out.println("<p>Order ID: <strong>" + orderId + "</strong></p>");

            if (orderRs.next()) {
                out.println("<p><strong>Customer:</strong> " + orderRs.getString("name") + "<br>");
                out.println("<strong>Email:</strong> " + orderRs.getString("email") + "<br>");
                out.println("<strong>Phone:</strong> " + orderRs.getString("phone") + "<br>");
                out.println("<strong>Address:</strong> " + orderRs.getString("address") + "<br>");
                out.println("<strong>Date:</strong> " + orderRs.getTimestamp("order_date") + "</p>");
            }

            out.println("<table>");
            out.println("<tr><th>Item</th><th>Qty</th><th>Rate</th><th>Total</th></tr>");

            double subtotal = 0;
            while (itemsRs.next()) {
                String item = itemsRs.getString("item_name");
                int qty = itemsRs.getInt("quantity");
                double price = itemsRs.getDouble("price_per_item");
                double total = qty * price;
                subtotal += total;

                out.println("<tr>");
                out.println("<td>" + item + "</td>");
                out.println("<td>" + qty + "</td>");
                out.println("<td>₹ " + String.format("%.2f", price) + "</td>");
                out.println("<td>₹ " + String.format("%.2f", total) + "</td>");
                out.println("</tr>");
            }

            double cgst = subtotal * 0.09;
            double sgst = subtotal * 0.09;
            double grandTotal = subtotal + cgst + sgst;

            out.println("</table>");
            out.println("<p><strong>Subtotal:</strong> ₹ " + String.format("%.2f", subtotal) + "</p>");
            out.println("<p><strong>CGST (9%):</strong> ₹ " + String.format("%.2f", cgst) + "</p>");
            out.println("<p><strong>SGST (9%):</strong> ₹ " + String.format("%.2f", sgst) + "</p>");
            out.println("<h3>Total Amount: ₹ " + String.format("%.2f", grandTotal) + "</h3>");

            out.println("<br><button onclick='window.print()'>🖨️ Print Bill</button>");

            out.println("</body></html>");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error generating bill.");
        }
    }

    // Optional: route GET to POST
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }
}
