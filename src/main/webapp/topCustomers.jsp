<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, com.inventory.utils.DBUtil" %>
<!DOCTYPE html>
<html>
<head>
    <title>👑 Top Customers</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
        }
        h2 {
            font-weight: bold;
        }
        .table th, .table td {
            vertical-align: middle;
            text-align: center;
        }
    </style>
</head>
<body>
<div class="container mt-5">
    <h2>👑 Top Customers</h2>
    <a href="dashboard.jsp" class="btn btn-secondary mb-3">← Back to Dashboard</a>

    <%
        String query = "SELECT c.name, c.email, c.phone, " +
                       "SUM(o.total_amount) AS total_spent, COUNT(o.order_id) AS total_orders " +
                       "FROM customers c JOIN orders o ON c.customer_id = o.customer_id " +
                       "GROUP BY c.customer_id ORDER BY total_spent DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {
    %>

    <div class="table-responsive">
        <table class="table table-bordered table-striped mt-3">
            <thead class="table-dark">
                <tr>
                    <th>#</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Phone</th>
                    <th>Total Orders</th>
                    <th>Total Spent (₹)</th>
                </tr>
            </thead>
            <tbody>
            <%
                int rank = 1;
                boolean hasResults = false;
                while (rs.next()) {
                    hasResults = true;
            %>
                <tr>
                    <td><strong><%= rank++ %></strong></td>
                    <td><%= rs.getString("name") %></td>
                    <td><%= rs.getString("email") %></td>
                    <td><%= rs.getString("phone") %></td>
                    <td><%= rs.getInt("total_orders") %></td>
                    <td class="text-success fw-bold">₹<%= String.format("%.2f", rs.getDouble("total_spent")) %></td>
                </tr>
            <%
                }
                if (!hasResults) {
            %>
                <tr><td colspan="6" class="text-center text-muted">No customer data available.</td></tr>
            <%
                }
            %>
            </tbody>
        </table>
    </div>

    <% } catch (Exception e) { %>
        <div class="alert alert-danger">⚠️ Error loading top customers.</div>
        <pre><%= e.getMessage() %></pre>
    <% } %>
</div>
</body>
</html>
