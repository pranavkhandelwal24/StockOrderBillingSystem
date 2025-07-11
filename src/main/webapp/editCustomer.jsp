<%@ page import="java.sql.*" %>
<%@ page import="com.inventory.utils.DBUtil" %>
<%
    int id = Integer.parseInt(request.getParameter("id"));
    String name = "", email = "", phone = "", address = "";

    try (Connection conn = DBUtil.getConnection()) {
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM customers WHERE customer_id = ?");
        ps.setInt(1, id);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            name = rs.getString("name");
            email = rs.getString("email");
            phone = rs.getString("phone");
            address = rs.getString("address");
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Customer</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-5">
    <h2> Edit Customer</h2>
    <form method="post" action="updateCustomer">
        <input type="hidden" name="customer_id" value="<%= id %>">
        <div class="mb-3">
            <label>Name:</label>
            <input type="text" name="name" value="<%= name %>" class="form-control" required>
        </div>
        <div class="mb-3">
            <label>Email:</label>
            <input type="email" name="email" value="<%= email %>" class="form-control" required>
        </div>
        <div class="mb-3">
            <label>Phone:</label>
            <input type="text" name="phone" value="<%= phone %>" class="form-control" required>
        </div>
        <div class="mb-3">
            <label>Address:</label>
            <textarea name="address" class="form-control" required><%= address %></textarea>
        </div>
        <button type="submit" class="btn btn-success"> Save Changes</button>
        <a href="customerList.jsp" class="btn btn-secondary"> Back</a>
    </form>
</div>
</body>
</html>
