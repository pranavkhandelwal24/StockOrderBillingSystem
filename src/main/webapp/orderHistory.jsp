<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, com.inventory.utils.DBUtil" %>
<!DOCTYPE html>
<html>
<head>
    <title>🧾 Order History</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-5">
    <h2>🧾 Order History</h2>
    <a href="dashboard.jsp" class="btn btn-secondary mb-3">← Back to Dashboard</a>

    <table class="table table-striped table-bordered">
        <thead class="table-dark">
            <tr>
                <th>Order ID</th>
                <th>Customer</th>
                <th>Email</th>
                <th>Phone</th>
                <th>Total Amount</th>
                <th>Order Date</th>
                <th>Download Bill</th>
            </tr>
        </thead>
        <tbody>
        <%
            try (Connection conn = DBUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement(
                     "SELECT o.order_id, o.order_date, o.total_amount, " +
                     "c.name, c.email, c.phone " +
                     "FROM orders o JOIN customers c ON o.customer_id = c.customer_id " +
                     "ORDER BY o.order_date DESC");
                 ResultSet rs = ps.executeQuery()) {

                boolean hasOrders = false;
                while (rs.next()) {
                    hasOrders = true;
        %>
            <tr>
                <td><%= rs.getInt("order_id") %></td>
                <td><%= rs.getString("name") %></td>
                <td><%= rs.getString("email") %></td>
                <td><%= rs.getString("phone") %></td>
                <td>₹<%= rs.getBigDecimal("total_amount") %></td>
                <td><%= rs.getTimestamp("order_date") %></td>
                <td>
                    <a href="viewBill.jsp?orderId=<%= rs.getInt("order_id") %>" class="btn btn-sm btn-outline-primary">
                        View Bill
                    </a>
                </td>
            </tr>
        <%
                }
                if (!hasOrders) {
        %>
            <tr>
                <td colspan="7" class="text-center text-muted">No orders found.</td>
            </tr>
        <%
                }
            } catch (Exception e) {
                out.println("<tr><td colspan='7'>Error loading order history.</td></tr>");
                e.printStackTrace();
            }
        %>
        </tbody>
    </table>
</div>
</body>
</html>
