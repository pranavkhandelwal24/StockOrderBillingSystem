package com.inventory.controller;

import com.inventory.utils.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet("/AdjustStockServlet")
public class AdjustStockServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String stockIdParam = request.getParameter("stock_id");
        String type = request.getParameter("adjustment_type");
        String qtyParam = request.getParameter("quantity_change");
        String reason = request.getParameter("reason");

        if (stockIdParam == null || qtyParam == null || stockIdParam.isEmpty() || qtyParam.isEmpty()) {
            response.sendRedirect("adjustStock.jsp?error=missingInput");
            return;
        }

        try {
            int stockId = Integer.parseInt(stockIdParam);
            int quantityChange = Integer.parseInt(qtyParam);

            // Convert to negative if return or correction
            if ("return".equals(type) || "correction".equals(type)) {
                quantityChange = -Math.abs(quantityChange);
            }

            try (Connection conn = DBUtil.getConnection()) {
                // 1. Insert adjustment record
                String insertAdjustmentSql = "INSERT INTO stock_adjustments (stock_id, adjustment_type, quantity_change, reason) VALUES (?, ?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(insertAdjustmentSql)) {
                    ps.setInt(1, stockId);
                    ps.setString(2, type);
                    ps.setInt(3, quantityChange);
                    ps.setString(4, reason);
                    ps.executeUpdate();
                }

                // 2. Update stock quantity
                String updateStockSql = "UPDATE stock SET quantity = quantity + ? WHERE stock_id = ?";
                try (PreparedStatement updateStock = conn.prepareStatement(updateStockSql)) {
                    updateStock.setInt(1, quantityChange);
                    updateStock.setInt(2, stockId);
                    updateStock.executeUpdate();
                }

                response.sendRedirect("adjustStock.jsp?success=true");
            }

        } catch (NumberFormatException e) {
            e.printStackTrace();
            response.sendRedirect("adjustStock.jsp?error=invalidNumber");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("adjustStock.jsp?error=internal");
        }
    }
}
