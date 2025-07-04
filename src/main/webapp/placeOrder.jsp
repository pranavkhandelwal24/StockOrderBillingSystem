<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.util.*, java.sql.*" %>
<%@ page import="com.inventory.utils.DBUtil" %>
<!DOCTYPE html>
<html>
<head>
    <title>Place Order</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="js/place_order.js" defer></script>
</head>
<body>
<div class="container mt-4">
    <h2 class="mb-4">🛒 Place New Order</h2>
    <a href="dashboard.jsp" class="btn btn-secondary mb-3">← Back to Dashboard</a>

    <form action="placeOrder" method="post" id="orderForm">
        <h5>👤 Customer Details</h5>
        <div class="row mb-3">
            <div class="col-md-4">
                <label>Email (existing):</label>
                <input type="email" name="email" class="form-control" id="email" onchange="fetchCustomer()" required>
            </div>
            <div class="col-md-4">
                <label>Name:</label>
                <input type="text" name="name" class="form-control" id="name" required>
            </div>
            <div class="col-md-4">
                <label>Phone:</label>
                <input type="text" name="phone" class="form-control" id="phone" required>
            </div>
            <div class="col-md-12 mt-2">
                <label>Address:</label>
                <textarea name="address" class="form-control" id="address" required></textarea>
            </div>
        </div>

        <h5 class="mt-4">📦 Order Items</h5>
        <div id="itemsContainer"></div>

        <button type="button" class="btn btn-secondary mt-3" onclick="addItemRow()">➕ Add Item</button>
        <button type="submit" class="btn btn-success mt-3">✅ Place Order</button>
    </form>
</div>
</body>
</html>
