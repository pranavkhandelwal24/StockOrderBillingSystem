<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Add Stock</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-5">
    <h2 class="mb-4">Add New Stock Item</h2>
    <a href="dashboard.jsp" class="btn btn-secondary mb-3">← Back to Dashboard</a>

    <form action="addStock" method="post">
        <div class="mb-3">
            <label>Item Name:</label>
            <input type="text" class="form-control" name="item_name" required>
        </div>
        <div class="mb-3">
            <label>Description:</label>
            <textarea class="form-control" name="description"></textarea>
        </div>
        <div class="mb-3">
            <label>Quantity:</label>
            <input type="number" class="form-control" name="quantity" required min="1">
        </div>
        <div class="mb-3">
            <label>Price:</label>
            <input type="number" class="form-control" name="price" step="0.01" required>
        </div>
        <button type="submit" class="btn btn-primary">Add Stock</button>
    </form>

    <c:if test="${not empty message}">
        <div class="alert alert-info mt-3">${message}</div>
    </c:if>
</div>
</body>
</html>
