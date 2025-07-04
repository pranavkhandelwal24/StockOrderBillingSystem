<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="java.sql.*, com.inventory.utils.DBUtil" %>
<!DOCTYPE html>
<html>
<head>
    <title>Top Customers</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-4">
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

    <table class="table table-striped mt-3">
        <thead>
            <tr>
                <th>Name</th>
                <th>Email</th>
                <th>Phone</th>
                <th>Total Orders</th>
                <th>Total Spent (₹)</th>
            </tr>
        </thead>
        <tbody>
        <%
            boolean hasResults = false;
            while (rs.next()) {
                hasResults = true;
        %>
            <tr>
                <td><%= rs.getString("name") %></td>
                <td><%= rs.getString("email") %></td>
                <td><%= rs.getString("phone") %></td>
                <td><%= rs.getInt("total_orders") %></td>
                <td><%= rs.getDouble("total_spent") %></td>
            </tr>
        <% } %>
        <% if (!hasResults) { %>
            <tr><td colspan="5" class="text-center text-muted">No customers found.</td></tr>
        <% } %>
        </tbody>
    </table>

    <% } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Error loading top customers.</div>");
        e.printStackTrace();
    } %>
</div>
</body>
</html>
