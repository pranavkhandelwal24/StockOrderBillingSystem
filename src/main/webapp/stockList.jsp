<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.text.DecimalFormat, com.inventory.utils.DBUtil" %>
<!DOCTYPE html>
<html>
<head>
    <title>📋 Stock List - Inventory</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
        }
        h3 {
            font-weight: bold;
        }
        .table th, .table td {
            vertical-align: middle;
        }
    </style>
</head>
<body>
<div class="container mt-4">
    <h3 class="mb-4">📋 Current Stock Inventory</h3>

    <table class="table table-hover table-bordered">
        <thead class="table-dark text-center">
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
                DecimalFormat priceFormat = new DecimalFormat("#,##0.00");

                while (rs.next()) {
                    hasData = true;
                    String itemName = rs.getString("item_name");
                    String description = rs.getString("description");
                    int quantity = rs.getInt("quantity");
                    double price = rs.getDouble("price");
                    Timestamp updated = rs.getTimestamp("last_updated");
        %>
            <tr>
                <td class="text-center"><%= count++ %></td>
                <td><%= itemName %></td>
                <td><%= description != null ? description : "-" %></td>
                <td class="<%= quantity < 10 ? "text-danger fw-bold" : "" %>"><%= quantity %></td>
                <td>₹<%= priceFormat.format(price) %></td>
                <td><%= updated != null ? updated.toString() : "N/A" %></td>
            </tr>
        <%
                }

                if (!hasData) {
        %>
            <tr>
                <td colspan="6" class="text-center text-muted">📭 No stock items found.</td>
            </tr>
        <%
                }
            } catch (Exception e) {
                out.println("<tr><td colspan='6' class='text-danger text-center'>⚠️ Error loading stock data.</td></tr>");
                e.printStackTrace();
            }
        %>
        </tbody>
    </table>

    <a href="dashboard.jsp" class="btn btn-secondary mt-3">⬅ Back to Dashboard</a>
</div>
</body>
</html>
