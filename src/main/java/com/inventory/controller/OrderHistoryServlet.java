package com.inventory.controller;

import com.inventory.utils.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;

@WebServlet("/OrderHistoryServlet")
public class OrderHistoryServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public OrderHistoryServlet() {
		super();
	}

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		response.setContentType("text/html;charset=UTF-8");
		PrintWriter out = response.getWriter();

		try (Connection conn = DBUtil.getConnection();
			 PreparedStatement stmt = conn.prepareStatement(
					 "SELECT o.order_id, o.order_date, o.total_amount, c.name AS customer_name " +
					 "FROM orders o JOIN customers c ON o.customer_id = c.customer_id " +
					 "ORDER BY o.order_date DESC");
			 ResultSet rs = stmt.executeQuery()) {

			out.println("<html><head><title>Order History</title>");
			out.println("<style>table{border-collapse:collapse;width:100%;margin-top:20px;}");
			out.println("th,td{border:1px solid #ccc;padding:8px;text-align:left;}");
			out.println("th{background:#f2f2f2;}</style>");
			out.println("</head><body>");
			out.println("<h2>📦 Order History</h2>");
			out.println("<table>");
			out.println("<tr><th>Order ID</th><th>Customer</th><th>Date</th><th>Total (₹)</th></tr>");

			boolean hasData = false;
			while (rs.next()) {
				hasData = true;
				out.println("<tr>");
				out.println("<td>" + rs.getInt("order_id") + "</td>");
				out.println("<td>" + rs.getString("customer_name") + "</td>");
				out.println("<td>" + rs.getTimestamp("order_date") + "</td>");
				out.println("<td>" + String.format("%.2f", rs.getDouble("total_amount")) + "</td>");
				out.println("</tr>");
			}

			if (!hasData) {
				out.println("<tr><td colspan='4'>No orders found.</td></tr>");
			}

			out.println("</table>");
			out.println("</body></html>");

		} catch (SQLException e) {
			e.printStackTrace();
			out.println("<p style='color:red;'>Error retrieving order history.</p>");
		}
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}
}
