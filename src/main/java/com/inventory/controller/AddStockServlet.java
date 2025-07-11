package com.inventory.controller;

import com.inventory.utils.DBUtil;
import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;

public class AddStockServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        
        String itemName = request.getParameter("item_name");
        String description = request.getParameter("description");
        int quantity = Integer.parseInt(request.getParameter("quantity"));
        double price = Double.parseDouble(request.getParameter("price"));

        try (Connection conn = DBUtil.getConnection()) {
            String sql = "INSERT INTO stock (item_name, description, quantity, price) VALUES (?, ?, ?, ?)";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, itemName);
            stmt.setString(2, description);
            stmt.setInt(3, quantity);
            stmt.setDouble(4, price);

            int rows = stmt.executeUpdate();

            if (rows > 0) {
                request.setAttribute("message", "Stock item added successfully!");
            } else {
                request.setAttribute("message", "Failed to add stock item.");
            }

            RequestDispatcher rd = request.getRequestDispatcher("addStock.jsp");
            rd.forward(request, response);

        } catch (SQLException e) {
            throw new ServletException("DB Error: " + e.getMessage());
        }
    }
}
