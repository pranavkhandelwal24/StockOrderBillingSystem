<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, com.inventory.utils.DBUtil" %>
<!DOCTYPE html>
<html>
<head>
    <title>📅 Sales Report</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
        }
        h2 {
            font-weight: 600;
        }
        .table th, .table td {
            vertical-align: middle;
        }
    </style>
</head>
<body>
<div class="container mt-4">
    <h2>📅 Sales Report</h2>
    <a href="dashboard.jsp" class="btn btn-secondary mb-3">← Back to Dashboard</a>

    <!-- Date Filter Form -->
    <form method="get" class="row g-3 mb-4">
        <div class="col-md-4">
            <label class="form-label">From Date</label>
            <input type="date" name="from" class="form-control" required value="<%= request.getParameter("from") != null ? request.getParameter("from") : "" %>">
        </div>
        <div class="col-md-4">
            <label class="form-label">To Date</label>
            <input type="date" name="to" class="form-control" required value="<%= request.getParameter("to") != null ? request.getParameter("to") : "" %>">
        </div>
        <div class="col-md-4 d-flex align-items-end">
            <button type="submit" class="btn btn-primary w-100">🔍 Generate</button>
        </div>
    </form>

    <%
        String from = request.getParameter("from");
        String to = request.getParameter("to");

        if (from != null && to != null && !from.isEmpty() && !to.isEmpty()) {
            String query = "SELECT o.order_id, o.order_date, o.total_amount, c.name " +
                           "FROM orders o JOIN customers c ON o.customer_id = c.customer_id " +
                           "WHERE o.order_date BETWEEN ? AND ? ORDER BY o.order_date DESC";

            double totalRevenue = 0;
            int orderCount = 0;

            try (Connection conn = DBUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement(query)) {

                ps.setString(1, from + " 00:00:00");
                ps.setString(2, to + " 23:59:59");

                ResultSet rs = ps.executeQuery();
    %>

    <hr>
    <table class="table table-bordered table-striped mt-3">
        <thead class="table-dark">
            <tr>
                <th>Order ID</th>
                <th>Date</th>
                <th>Customer</th>
                <th>Total Amount (₹)</th>
            </tr>
        </thead>
        <tbody>
        <%
            while (rs.next()) {
                orderCount++;
                totalRevenue += rs.getDouble("total_amount");
        %>
            <tr>
                <td><%= rs.getInt("order_id") %></td>
                <td><%= rs.getTimestamp("order_date") %></td>
                <td><%= rs.getString("name") %></td>
                <td>₹<%= String.format("%.2f", rs.getDouble("total_amount")) %></td>
            </tr>
        <%
            }
            if (orderCount == 0) {
        %>
            <tr><td colspan="4" class="text-center text-muted">📭 No orders found in this range.</td></tr>
        <%
            }
        %>
        </tbody>
    </table>

    <!-- Summary Info -->
    <div class="alert alert-info">
        <strong>Total Orders:</strong> <%= orderCount %><br>
        <strong>Total Revenue:</strong> ₹ <%= String.format("%.2f", totalRevenue) %>
    </div>

    <%
            } catch (Exception e) {
                out.println("<div class='alert alert-danger'>❌ Error fetching report.</div>");
                e.printStackTrace();
            }
        }
    %>
</div>
</body>
</html>
