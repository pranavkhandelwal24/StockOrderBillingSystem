package com.inventory.controller;

import com.inventory.utils.DBUtil;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import org.json.JSONArray;
import org.json.JSONObject;

public class FetchCustomerNamesServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

        String query = request.getParameter("name");
        JSONArray results = new JSONArray();

        try (Connection conn = DBUtil.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "SELECT name, email, phone, address FROM customers WHERE name ILIKE ? LIMIT 10"
            );
            ps.setString(1, "%" + query + "%");
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                JSONObject obj = new JSONObject();
                obj.put("name", rs.getString("name"));
                obj.put("email", rs.getString("email"));
                obj.put("phone", rs.getString("phone"));
                obj.put("address", rs.getString("address"));
                results.put(obj);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        response.setContentType("application/json");
        response.getWriter().write(results.toString());
    }
}
