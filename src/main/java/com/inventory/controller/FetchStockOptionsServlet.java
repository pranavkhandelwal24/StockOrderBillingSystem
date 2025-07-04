package com.inventory.controller;

import com.inventory.utils.DBUtil;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;

public class FetchStockOptionsServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

        response.setContentType("text/html");
        try (Connection conn = DBUtil.getConnection()) {
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT stock_id, item_name FROM stock");

            PrintWriter out = response.getWriter();
            while (rs.next()) {
                out.println("<option value='" + rs.getInt("stock_id") + "'>" +
                            rs.getString("item_name") + "</option>");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
