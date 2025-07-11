<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.text.SimpleDateFormat, com.inventory.utils.DBUtil" %>
<!DOCTYPE html>
<html>
<head>
    <title>Order History</title>
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
                <th>View Bill</th>
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
                SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy, hh:mm a");

                while (rs.next()) {
                    hasOrders = true;
                    int orderId = rs.getInt("order_id");
                    String customer = rs.getString("name");
                    String email = rs.getString("email");
                    String phone = rs.getString("phone");
                    double amount = rs.getDouble("total_amount");
                    Timestamp orderDate = rs.getTimestamp("order_date");
        %>
            <tr>
                <td><%= orderId %></td>
                <td><%= customer %></td>
                <td><%= email %></td>
                <td><%= phone %></td>
                <td>₹<%= String.format("%.2f", amount) %></td>
                <td><%= sdf.format(orderDate) %></td>
                <td>
                    <a href="order_bill.jsp?orderId=123">View Bill</a>

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
