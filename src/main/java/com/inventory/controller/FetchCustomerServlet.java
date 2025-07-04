package com.inventory.controller;

import com.inventory.utils.DBUtil;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;

public class FetchCustomerServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        
        String email = request.getParameter("email");
        response.setContentType("application/json");

        try (Connection conn = DBUtil.getConnection()) {
            String sql = "SELECT * FROM customers WHERE email = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                response.getWriter().write("{\"found\":true," +
                    "\"name\":\"" + rs.getString("name") + "\"," +
                    "\"phone\":\"" + rs.getString("phone") + "\"," +
                    "\"address\":\"" + rs.getString("address") + "\"}");
            } else {
                response.getWriter().write("{\"found\":false}");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
