<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, com.inventory.utils.DBUtil" %>
<%@ page import="java.util.*" %>

<!DOCTYPE html>
<html>
<head>
    <title>🧾 Order History</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>

<div class="container mt-4">
    <h2>🕓 Order History</h2>
    <a href="dashboard.jsp" class="btn btn-secondary mb-3">← Back to Dashboard</a>

    <!-- 🔍 Search Form -->
    <form method="get" class="row g-3">
        <div class="col-md-4">
            <input type="email" name="email" class="form-control" placeholder="Customer Email (optional)" value="<%= request.getParameter("email") != null ? request.getParameter("email") : "" %>">
        </div>
        <div class="col-md-3">
            <input type="date" name="from" class="form-control" value="<%= request.getParameter("from") != null ? request.getParameter("from") : "" %>">
        </div>
        <div class="col-md-3">
            <input type="date" name="to" class="form-control" value="<%= request.getParameter("to") != null ? request.getParameter("to") : "" %>">
        </div>
        <div class="col-md-2">
            <button type="submit" class="btn btn-primary w-100">🔍 Search</button>
        </div>
    </form>

    <hr>

    <%
        String email = request.getParameter("email");
        String from = request.getParameter("from");
        String to = request.getParameter("to");

        String sql = "SELECT o.order_id, o.order_date, o.total_amount, c.name " +
                     "FROM orders o JOIN customers c ON o.customer_id = c.customer_id WHERE 1=1";
        List<Object> params = new ArrayList<>();

        if (email != null && !email.trim().isEmpty()) {
            sql += " AND c.email = ?";
            params.add(email.trim());
        }
        if (from != null && !from.trim().isEmpty()) {
            sql += " AND o.order_date >= ?";
            params.add(from + " 00:00:00");
        }
        if (to != null && !to.trim().isEmpty()) {
            sql += " AND o.order_date <= ?";
            params.add(to + " 23:59:59");
        }

        sql += " ORDER BY o.order_date DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            ResultSet rs = ps.executeQuery();
    %>

    <!-- 🧾 Orders Table -->
    <table class="table table-striped mt-3">
        <thead class="table-dark">
        <tr>
            <th>Order ID</th>
            <th>Date</th>
            <th>Customer</th>
            <th>Total (₹)</th>
            <th>Bill</th>
        </tr>
        </thead>
        <tbody>
        <%
            boolean found = false;
            while (rs.next()) {
                found = true;
                double total = rs.getDouble("total_amount");
                double cgst = total * 0.09;
                double sgst = total * 0.09;
                double base = total - cgst - sgst;
        %>
        <tr>
            <td><%= rs.getInt("order_id") %></td>
            <td><%= rs.getTimestamp("order_date") %></td>
            <td><%= rs.getString("name") %></td>
            <td>
                ₹ <%= String.format("%.2f", total) %><br>
                <small class="text-muted">
                    Base: ₹<%= String.format("%.2f", base) %>,
                    CGST: ₹<%= String.format("%.2f", cgst) %>,
                    SGST: ₹<%= String.format("%.2f", sgst) %>
                </small>
            </td>
            <td>
                <a href="viewBill.jsp?orderId=<%= rs.getInt("order_id") %>" class="btn btn-sm btn-outline-primary">View Bill</a>
            </td>
        </tr>
        <% } %>
        <% if (!found) { %>
        <tr><td colspan="5" class="text-center text-muted">No orders found for the given filters.</td></tr>
        <% } %>
        </tbody>
    </table>

    <% } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Error fetching orders.</div>");
        e.printStackTrace();
    } %>

</div>
</body>
</html>
