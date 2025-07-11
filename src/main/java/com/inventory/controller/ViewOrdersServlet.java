package com.inventory.controller;

import com.inventory.utils.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;

@WebServlet("/ViewOrdersServlet")
public class ViewOrdersServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public ViewOrdersServlet() {
        super();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                 "SELECT o.order_id, o.order_date, o.total_amount, c.name AS customer_name " +
                 "FROM orders o JOIN customers c ON o.customer_id = c.customer_id " +
                 "ORDER BY o.order_date DESC"
             );
             ResultSet rs = stmt.executeQuery()) {

            out.println("<html><head><title>All Orders</title>");
            out.println("<style>");
            out.println("table { border-collapse: collapse; width: 100%; margin-top: 20px; }");
            out.println("th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }");
            out.println("th { background-color: #f2f2f2; }");
            out.println("</style>");
            out.println("</head><body>");
            out.println("<h2>🧾 All Orders</h2>");

            out.println("<table>");
            out.println("<tr><th>Order ID</th><th>Customer</th><th>Date</th><th>Total (₹)</th><th>Actions</th></tr>");

            boolean hasOrders = false;

            while (rs.next()) {
                hasOrders = true;
                int orderId = rs.getInt("order_id");
                out.println("<tr>");
                out.println("<td>" + orderId + "</td>");
                out.println("<td>" + rs.getString("customer_name") + "</td>");
                out.println("<td>" + rs.getTimestamp("order_date") + "</td>");
                out.println("<td>₹ " + String.format("%.2f", rs.getDouble("total_amount")) + "</td>");
                out.println("<td><a href='viewBill.jsp?orderId=" + orderId + "'>🧾 View Bill</a></td>");
                out.println("</tr>");
            }

            if (!hasOrders) {
                out.println("<tr><td colspan='5'>No orders placed yet.</td></tr>");
            }

            out.println("</table>");
            out.println("</body></html>");

        } catch (Exception e) {
            e.printStackTrace();
            out.println("<p style='color:red;'>Failed to load orders.</p>");
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        doGet(request, response); // Let both GET and POST work the same
    }
}
