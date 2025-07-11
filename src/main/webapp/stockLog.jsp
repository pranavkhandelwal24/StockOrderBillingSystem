<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.text.SimpleDateFormat, com.inventory.utils.DBUtil" %>
<!DOCTYPE html>
<html>
<head>
    <title>📦 Stock Adjustment Log</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
        }
        h2 {
            font-weight: bold;
        }
        .table td, .table th {
            vertical-align: middle;
            text-align: center;
        }
        .text-success {
            font-weight: bold;
        }
        .text-danger {
            font-weight: bold;
        }
    </style>
</head>
<body>
<div class="container mt-4">
    <h2>📦 Stock Adjustment History</h2>
    <a href="dashboard.jsp" class="btn btn-secondary mb-3">← Back to Dashboard</a>

    <%
        String query = "SELECT sa.adjustment_id, sa.adjustment_type, sa.quantity_change, sa.reason, sa.adjusted_at, " +
                       "s.item_name FROM stock_adjustments sa JOIN stock s ON sa.stock_id = s.stock_id " +
                       "ORDER BY sa.adjusted_at DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {

        SimpleDateFormat sdf = new SimpleDateFormat("dd-MMM-yyyy hh:mm a");
    %>

    <table class="table table-bordered table-striped mt-3">
        <thead class="table-dark">
        <tr>
            <th>ID</th>
            <th>Item</th>
            <th>Type</th>
            <th>Qty Change</th>
            <th>Reason</th>
            <th>Adjusted At</th>
        </tr>
        </thead>
        <tbody>
        <%
            boolean found = false;
            while (rs.next()) {
                found = true;
                int qty = rs.getInt("quantity_change");
        %>
            <tr>
                <td><%= rs.getInt("adjustment_id") %></td>
                <td><%= rs.getString("item_name") %></td>
                <td><%= rs.getString("adjustment_type") %></td>
                <td class="<%= qty < 0 ? "text-danger" : "text-success" %>"><%= qty %></td>
                <td><%= rs.getString("reason") %></td>
                <td><%= sdf.format(rs.getTimestamp("adjusted_at")) %></td>
            </tr>
        <% } %>
        <% if (!found) { %>
            <tr>
                <td colspan="6" class="text-center text-muted">📭 No stock adjustments recorded yet.</td>
            </tr>
        <% } %>
        </tbody>
    </table>

    <% } catch (Exception e) { %>
        <div class="alert alert-danger">⚠️ Error loading stock log.</div>
        <pre><%= e.getMessage() %></pre>
    <% } %>
</div>
</body>
</html>
