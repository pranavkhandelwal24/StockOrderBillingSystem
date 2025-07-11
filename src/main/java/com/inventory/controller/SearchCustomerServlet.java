package com.inventory.controller;

import com.inventory.utils.DBUtil;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import org.json.JSONArray;
import org.json.JSONObject;

public class SearchCustomerServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

        String query = request.getParameter("query");
        response.setContentType("application/json");
        JSONArray result = new JSONArray();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                 "SELECT * FROM customers WHERE name LIKE ?")) {
            
            stmt.setString(1, "%" + query + "%");
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                JSONObject cust = new JSONObject();
                cust.put("name", rs.getString("name"));
                cust.put("email", rs.getString("email"));
                cust.put("phone", rs.getString("phone"));
                cust.put("address", rs.getString("address"));
                result.put(cust);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.getWriter().write(result.toString());
    }
}
