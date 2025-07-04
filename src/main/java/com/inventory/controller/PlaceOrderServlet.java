package com.inventory.controller;

import com.inventory.utils.DBUtil;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import java.util.*;

public class PlaceOrderServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");

        String[] itemIds = request.getParameterValues("item_id");
        String[] itemQtys = request.getParameterValues("item_qty");

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false); // Transaction start

            // 1. Check if customer exists
            int customerId;
            PreparedStatement checkStmt = conn.prepareStatement("SELECT customer_id FROM customers WHERE email = ?");
            checkStmt.setString(1, email);
            ResultSet rs = checkStmt.executeQuery();

            if (rs.next()) {
                customerId = rs.getInt("customer_id");
            } else {
                PreparedStatement insertCust = conn.prepareStatement(
                        "INSERT INTO customers (name, email, phone, address) VALUES (?, ?, ?, ?)",
                        Statement.RETURN_GENERATED_KEYS);
                insertCust.setString(1, name);
                insertCust.setString(2, email);
                insertCust.setString(3, phone);
                insertCust.setString(4, address);
                insertCust.executeUpdate();
                ResultSet keys = insertCust.getGeneratedKeys();
                keys.next();
                customerId = keys.getInt(1);
            }

            // 2. Create Order
            PreparedStatement orderStmt = conn.prepareStatement(
                    "INSERT INTO orders (customer_id, total_amount) VALUES (?, ?)", Statement.RETURN_GENERATED_KEYS);
            orderStmt.setInt(1, customerId);
            orderStmt.setDouble(2, 0.0); // Temp, update later
            orderStmt.executeUpdate();
            ResultSet orderKeys = orderStmt.getGeneratedKeys();
            orderKeys.next();
            int orderId = orderKeys.getInt(1);

            double totalAmount = 0.0;

            // 3. Process each item
            PreparedStatement stockStmt = conn.prepareStatement("SELECT quantity, price FROM stock WHERE stock_id = ?");
            PreparedStatement updateStockStmt = conn.prepareStatement("UPDATE stock SET quantity = quantity - ? WHERE stock_id = ?");
            PreparedStatement insertItemStmt = conn.prepareStatement("INSERT INTO order_items (order_id, stock_id, quantity, price_per_item) VALUES (?, ?, ?, ?)");

            for (int i = 0; i < itemIds.length; i++) {
                int stockId = Integer.parseInt(itemIds[i]);
                int qty = Integer.parseInt(itemQtys[i]);

                // Check stock
                stockStmt.setInt(1, stockId);
                ResultSet stockRs = stockStmt.executeQuery();
                if (stockRs.next()) {
                    int available = stockRs.getInt("quantity");
                    double price = stockRs.getDouble("price");

                    if (qty > available) {
                        conn.rollback();
                        request.setAttribute("message", "Item ID " + stockId + " has only " + available + " units left.");
                        request.getRequestDispatcher("placeOrder.jsp").forward(request, response);
                        return;
                    }

                    // Insert into order_items
                    insertItemStmt.setInt(1, orderId);
                    insertItemStmt.setInt(2, stockId);
                    insertItemStmt.setInt(3, qty);
                    insertItemStmt.setDouble(4, price);
                    insertItemStmt.executeUpdate();

                    // Update stock
                    updateStockStmt.setInt(1, qty);
                    updateStockStmt.setInt(2, stockId);
                    updateStockStmt.executeUpdate();

                    totalAmount += price * qty;
                }
            }

            // 4. Update total in orders table
            PreparedStatement updateTotal = conn.prepareStatement("UPDATE orders SET total_amount = ? WHERE order_id = ?");
            updateTotal.setDouble(1, totalAmount);
            updateTotal.setInt(2, orderId);
            updateTotal.executeUpdate();

            conn.commit(); // Done

            // 5. Redirect to bill
            response.sendRedirect("viewBill.jsp?orderId=" + orderId);

        } catch (SQLException e) {
            throw new ServletException("Order processing failed: " + e.getMessage());
        }
    }
}
