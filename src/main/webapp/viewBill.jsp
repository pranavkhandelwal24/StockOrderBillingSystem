<%@ page import="java.sql.*, java.text.DecimalFormat" %>
<%@ page import="com.inventory.utils.DBUtil" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    int orderId = Integer.parseInt(request.getParameter("orderId"));
    Connection conn = DBUtil.getConnection();

    PreparedStatement orderStmt = conn.prepareStatement(
        "SELECT o.order_id, o.order_date, o.total_amount, c.name, c.email, c.phone, c.address " +
        "FROM orders o JOIN customers c ON o.customer_id = c.customer_id WHERE o.order_id = ?");
    orderStmt.setInt(1, orderId);
    ResultSet orderRs = orderStmt.executeQuery();

    PreparedStatement itemStmt = conn.prepareStatement(
        "SELECT s.item_name, oi.quantity, oi.price_per_item " +
        "FROM order_items oi JOIN stock s ON oi.stock_id = s.stock_id WHERE oi.order_id = ?");
    itemStmt.setInt(1, orderId);
    ResultSet itemRs = itemStmt.executeQuery();

    DecimalFormat df = new DecimalFormat("0.00");
    double cgstRate = 0.09;
    double sgstRate = 0.09;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Order Invoice</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; font-family: 'Segoe UI', sans-serif; }
        .invoice-box {
            background: #ffffff;
            padding: 30px;
            border-radius: 6px;
            box-shadow: 0 0 8px rgba(0,0,0,0.05);
        }
        .table th, .table td {
            vertical-align: middle !important;
        }
        .section-title {
            font-size: 1.5rem;
            font-weight: 600;
            margin-bottom: 20px;
            color: #343a40;
        }
        .logo {
            max-height: 70px;
        }
        @media print {
            .no-print {
                display: none;
            }
        }
    </style>
</head>
<body>

<div class="container mt-4 invoice-box" id="billContent">
    <!-- Company Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <img src="logo.png" alt="Company Logo" class="logo mb-2"><br>
            <strong>My Company Pvt. Ltd.</strong><br>
            GSTIN: 12ABCDE3456F7Z8<br>
            support@company.com
        </div>
        <div>
            <!-- QR Code -->
            <img src="https://chart.googleapis.com/chart?cht=qr&chs=100x100&chl=Order%20ID%20<%= orderId %>" alt="QR Code">
        </div>
    </div>

    <div class="text-center section-title">Order Invoice</div>

    <%
        if (orderRs.next()) {
    %>
    <!-- Customer Info -->
    <div class="row mb-3">
        <div class="col-md-6">
            <p><strong>Customer:</strong> <%= orderRs.getString("name") %></p>
            <p><strong>Email:</strong> <%= orderRs.getString("email") %></p>
            <p><strong>Phone:</strong> <%= orderRs.getString("phone") %></p>
            <p><strong>Address:</strong> <%= orderRs.getString("address") %></p>
        </div>
        <div class="col-md-6 text-end">
            <p><strong>Order ID:</strong> <%= orderId %></p>
            <p><strong>Date:</strong> <%= orderRs.getTimestamp("order_date") %></p>
        </div>
    </div>

    <!-- Items Table -->
    <table class="table table-bordered">
        <thead class="table-light">
        <tr>
            <th>#</th>
            <th>Item</th>
            <th>Qty</th>
            <th>Price (₹)</th>
            <th>Total (₹)</th>
        </tr>
        </thead>
        <tbody>
        <%
            int count = 1;
            double subtotal = 0;
            while (itemRs.next()) {
                int qty = itemRs.getInt("quantity");
                double price = itemRs.getDouble("price_per_item");
                double total = qty * price;
                subtotal += total;
        %>
        <tr>
            <td><%= count++ %></td>
            <td><%= itemRs.getString("item_name") %></td>
            <td><%= qty %></td>
            <td><%= df.format(price) %></td>
            <td><%= df.format(total) %></td>
        </tr>
        <% } %>

        <%
            double cgst = subtotal * cgstRate;
            double sgst = subtotal * sgstRate;
            double grandTotal = subtotal + cgst + sgst;
        %>

        <tr class="text-end">
            <td colspan="4">Subtotal</td>
            <td class="text-center">₹ <%= df.format(subtotal) %></td>
        </tr>
        <tr class="text-end">
            <td colspan="4">CGST (9%)</td>
            <td class="text-center">₹ <%= df.format(cgst) %></td>
        </tr>
        <tr class="text-end">
            <td colspan="4">SGST (9%)</td>
            <td class="text-center">₹ <%= df.format(sgst) %></td>
        </tr>
        <tr class="table-secondary fw-bold text-end">
            <td colspan="4">Grand Total</td>
            <td class="text-center">₹ <%= df.format(grandTotal) %></td>
        </tr>
        </tbody>
    </table>
    <% } else { %>
        <div class="alert alert-danger">Order not found.</div>
    <% } %>
</div>

<!-- Action Buttons -->
<div class="text-center mt-4 mb-5 no-print">
    <button class="btn btn-outline-dark" onclick="window.print()">Print Invoice</button>
    <a href="exportPDF?orderId=<%= orderId %>" class="btn btn-outline-primary">Download PDF</a>
    <a href="exportExcel?orderId=<%= orderId %>" class="btn btn-outline-success">Export Excel</a>
    <a href="dashboard.jsp" class="btn btn-secondary">Back to Dashboard</a>
</div>

</body>
</html>
