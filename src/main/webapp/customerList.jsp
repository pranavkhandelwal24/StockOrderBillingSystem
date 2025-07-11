<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="com.inventory.utils.DBUtil" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Customer List</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-5">
    <h2>�� Customer List</h2>
    <a href="dashboard.jsp" class="btn btn-secondary mb-3">← Back to Dashboard</a>

    <table class="table table-bordered table-hover">
        <thead class="table-dark">
            <thead class="table-dark">
    <tr>
        <th>#</th>
        <th>Name</th>
        <th>Email</th>
        <th>Phone</th>
        <th>Address</th>
        <th>Actions</th>
    </tr>
</thead>

        </thead>
        <tbody>
        <%
            try (Connection conn = DBUtil.getConnection()) {
                PreparedStatement stmt = conn.prepareStatement("SELECT * FROM customers ORDER BY customer_id DESC");
                ResultSet rs = stmt.executeQuery();
                int count = 1;
                while (rs.next()) {
        %>
            <tr>
    <td><%= count++ %></td>
    <td><%= rs.getString("name") %></td>
    <td><%= rs.getString("email") %></td>
    <td><%= rs.getString("phone") %></td>
    <td><%= rs.getString("address") %></td>
    <td>
        <a href="editCustomer.jsp?id=<%= rs.getInt("customer_id") %>" class="btn btn-sm btn-primary">✏️ Edit</a>
    </td>
</tr>

        <%
                }
            } catch (Exception e) {
                out.println("<tr><td colspan='5' class='text-danger'>Error: " + e.getMessage() + "</td></tr>");
            }
        %>
        </tbody>
    </table>
</div>
</body>
</html>
