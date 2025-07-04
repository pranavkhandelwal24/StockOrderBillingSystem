<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, com.inventory.utils.DBUtil" %>
<!DOCTYPE html>
<html>
<head>
    <title>📋 Stock List - Inventory</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-4">
    <h3 class="mb-4">📋 Current Stock Inventory</h3>

    <table class="table table-hover table-bordered">
        <thead class="table-light">
            <tr>
                <th>#</th>
                <th>Item Name</th>
                <th>Description</th>
                <th>Quantity</th>
                <th>Price (₹)</th>
                <th>Last Updated</th>
            </tr>
        </thead>
        <tbody>
            <%
                try (Connection conn = DBUtil.getConnection();
                     PreparedStatement ps = conn.prepareStatement("SELECT * FROM stock ORDER BY item_name ASC");
                     ResultSet rs = ps.executeQuery()) {

                    int count = 1;
                    boolean hasData = false;

                    while (rs.next()) {
                        hasData = true;
            %>
            <tr>
                <td><%= count++ %></td>
                <td><%= rs.getString("item_name") %></td>
                <td><%= rs.getString("description") %></td>
                <td><%= rs.getInt("quantity") %></td>
                <td><%= rs.getBigDecimal("price") %></td>
                <td><%= rs.getTimestamp("last_updated") %></td>
            </tr>
            <%
                    }

                    if (!hasData) {
            %>
            <tr>
                <td colspan="6" class="text-center text-muted">No stock items found.</td>
            </tr>
            <%
                    }
                } catch (Exception e) {
                    out.println("<tr><td colspan='6' class='text-danger'>⚠️ Error loading stock data</td></tr>");
                    e.printStackTrace();
                }
            %>
        </tbody>
    </table>

    <a href="dashboard.jsp" class="btn btn-secondary mt-3">⬅ Back to Dashboard</a>
</div>
</body>
</html>
