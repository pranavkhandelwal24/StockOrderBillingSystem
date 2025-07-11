package com.inventory.controller;

import com.inventory.utils.DBUtil;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;

public class AddCustomerServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");

        try (Connection conn = DBUtil.getConnection()) {
            PreparedStatement stmt = conn.prepareStatement(
                "INSERT INTO customers (name, email, phone, address) VALUES (?, ?, ?, ?)"
            );
            stmt.setString(1, name);
            stmt.setString(2, email);
            stmt.setString(3, phone);
            stmt.setString(4, address);
            stmt.executeUpdate();

            response.sendRedirect("dashboard.jsp?msg=Customer+Added+Successfully");
        } catch (SQLException e) {
            throw new ServletException("DB Error: " + e.getMessage(), e);
        }
    }
}
