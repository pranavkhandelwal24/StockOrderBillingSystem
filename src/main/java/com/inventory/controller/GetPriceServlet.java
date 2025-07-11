package com.inventory.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONObject;

import com.inventory.utils.DBUtil;

@WebServlet("/getPrice")
public class GetPriceServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int stockId = Integer.parseInt(request.getParameter("stockId"));

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT price FROM stock WHERE stock_id = ?")) {
            ps.setInt(1, stockId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                double price = rs.getDouble("price");
                response.setContentType("application/json");
                response.getWriter().write("{\"price\":" + price + "}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("application/json");
            response.getWriter().write("{\"price\":0}");
        }
    }
}