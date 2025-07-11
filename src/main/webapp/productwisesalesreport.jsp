<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, com.inventory.utils.DBUtil" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html>
<head>
    <title>📊 Product-wise Sales Report</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
        }
        h2 {
            font-weight: 600;
        }
        .table td, .table th {
            vertical-align: middle;
        }
    </style>
</head>
<body>
<div class="container mt-5">
    <h2>📊 Product-wise Sales Report</h2>
    <a href="dashboard.jsp" class="btn btn-secondary mb-3">← Back to Dashboard</a>

    <table class="table table-bordered table-striped">
        <thead class="table-dark">
            <tr>
                <th>Item Name</th>
                <th>Total Quantity Sold</th>
                <th>Total Revenue</th>
                <th>Last Sold Date</th>
            </tr>
        </thead>
        <tbody>
            <%
                try (
                    Connection conn = DBUtil.getConnection();
                    PreparedStatement ps = conn.prepareStatement(
                        "SELECT s.item_name, " +
                        "SUM(oi.quantity) AS total_sold, " +
                        "SUM(oi.quantity * oi.price_per_item) AS total_revenue, " +
                        "MAX(o.order_date) AS last_sold " +
                        "FROM order_items oi " +
                        "JOIN stock s ON oi.stock_id = s.stock_id " +
                        "JOIN orders o ON oi.order_id = o.order_id " +
                        "GROUP BY s.item_name " +
                        "ORDER BY total_revenue DESC"
                    );
                    ResultSet rs = ps.executeQuery()
                ) {
                    SimpleDateFormat sdf = new SimpleDateFormat("dd-MMM-yyyy");
                    boolean hasData = false;
                    while (rs.next()) {
                        hasData = true;
                        String itemName = rs.getString("item_name");
                        int totalSold = rs.getInt("total_sold");
                        double revenue = rs.getDouble("total_revenue");
                        Timestamp lastSold = rs.getTimestamp("last_sold");
            %>
            <tr>
                <td><%= itemName %></td>
                <td><%= totalSold %></td>
                <td>₹<%= String.format("%.2f", revenue) %></td>
                <td><%= lastSold != null ? sdf.format(lastSold) : "N/A" %></td>
            </tr>
            <%
                    }
                    if (!hasData) {
            %>
            <tr>
                <td colspan="4" class="text-center text-muted">📭 No sales data available.</td>
            </tr>
            <%
                    }
                } catch (Exception e) {
                    out.println("<tr><td colspan='4'>❌ Error loading sales report.</td></tr>");
                    e.printStackTrace();
                }
            %>
        </tbody>
    </table>
</div>
</body>
</html>
