package com.inventory.controller;

import com.inventory.utils.DBUtil;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import org.json.*;

public class CustomerSearchServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

        String term = request.getParameter("term");

        response.setContentType("application/json");
        JSONArray suggestions = new JSONArray();

        try (Connection conn = DBUtil.getConnection()) {
            PreparedStatement ps = conn.prepareStatement("SELECT * FROM customers WHERE name ILIKE ? LIMIT 10");
            ps.setString(1, "%" + term + "%");
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                JSONObject obj = new JSONObject();
                obj.put("label", rs.getString("name"));  // for display
                obj.put("value", rs.getString("name"));  // for field value
                obj.put("email", rs.getString("email"));
                obj.put("phone", rs.getString("phone"));
                obj.put("address", rs.getString("address"));
                suggestions.put(obj);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.getWriter().write(suggestions.toString());
    }
}
