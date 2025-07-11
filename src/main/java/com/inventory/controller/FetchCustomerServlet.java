package com.inventory.controller;

import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import org.json.JSONObject;
import com.inventory.utils.DBUtil;


public class FetchCustomerServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String email = request.getParameter("email");
        response.setContentType("application/json");

        try (Connection conn = DBUtil.getConnection()) {
            PreparedStatement stmt = conn.prepareStatement("SELECT name, email, phone, address FROM customers WHERE email = ?");
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                JSONObject json = new JSONObject();
                json.put("name", rs.getString("name"));
                json.put("email", rs.getString("email"));
                json.put("phone", rs.getString("phone"));
                json.put("address", rs.getString("address"));
                response.getWriter().print(json.toString());
            } else {
                response.setStatus(404);
                response.getWriter().print("{\"error\":\"Customer not found\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(500);
            response.getWriter().print("{\"error\":\"Server error\"}");
        }
    }
}
