package com.inventory.controller;

import com.inventory.utils.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;

@WebServlet("/LowStockServlet")
public class LowStockServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public LowStockServlet() {
        super();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement("SELECT stock_id, item_name, quantity FROM stock WHERE quantity < 10");
             ResultSet rs = stmt.executeQuery()) {

            out.println("<html><head><title>Low Stock Report</title>");
            out.println("<style>table { border-collapse: collapse; width: 60%; }" +
                        "th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }" +
                        "th { background-color: #f2f2f2; }</style>");
            out.println("</head><body>");
            out.println("<h2>🚨 Low Stock Items (Below 10)</h2>");
            out.println("<table>");
            out.println("<tr><th>ID</th><th>Item Name</th><th>Quantity</th></tr>");

            boolean hasResults = false;
            while (rs.next()) {
                hasResults = true;
                out.println("<tr>");
                out.println("<td>" + rs.getInt("stock_id") + "</td>");
                out.println("<td>" + rs.getString("item_name") + "</td>");
                out.println("<td>" + rs.getInt("quantity") + "</td>");
                out.println("</tr>");
            }

            if (!hasResults) {
                out.println("<tr><td colspan='3'>All items are sufficiently stocked.</td></tr>");
            }

            out.println("</table>");
            out.println("</body></html>");

        } catch (SQLException e) {
            e.printStackTrace();
            out.println("<p style='color:red;'>Error fetching low stock items.</p>");
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response); // Allow both GET and POST
    }
}
