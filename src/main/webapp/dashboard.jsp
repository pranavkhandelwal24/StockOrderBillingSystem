<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, com.inventory.utils.DBUtil" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Dashboard - Stock Order Billing System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f4f6f9;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        h2 {
            font-weight: 600;
            color: #343a40;
        }

        .btn {
            padding: 10px 16px;
        }

        .card-grid .col-md-3 {
            margin-bottom: 20px;
        }

        .card-grid .btn {
            height: 60px;
            font-weight: 500;
        }

        .metrics .alert {
            font-size: 1rem;
            border-left: 4px solid #007bff;
            background-color: #f8f9fa;
            color: #212529;
        }

        .section-heading {
            border-bottom: 1px solid #dee2e6;
            padding-bottom: 8px;
            margin-bottom: 20px;
            font-size: 1.25rem;
            color: #495057;
        }

        .low-stock .table th,
        .low-stock .table td {
            vertical-align: middle;
        }
    </style>
</head>
<body>

<div class="container mt-5">

    <!-- Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2>Stock Order Billing Dashboard</h2>
    </div>

    <!-- Metrics Section -->
    <div class="row metrics mb-4">
        <%
            try (Connection conn = DBUtil.getConnection()) {
                PreparedStatement totalOrders = conn.prepareStatement("SELECT COUNT(*) FROM orders");
                PreparedStatement totalCustomers = conn.prepareStatement("SELECT COUNT(*) FROM customers");
                PreparedStatement totalStockValue = conn.prepareStatement("SELECT SUM(quantity * price) FROM stock");

                ResultSet ordersRs = totalOrders.executeQuery();
                ResultSet custRs = totalCustomers.executeQuery();
                ResultSet valueRs = totalStockValue.executeQuery();

                ordersRs.next();
                custRs.next();
                valueRs.next();
        %>
        <div class="col-md-4">
            <div class="alert shadow-sm">Total Orders: <strong><%= ordersRs.getInt(1) %></strong></div>
        </div>
        <div class="col-md-4">
            <div class="alert shadow-sm">Total Customers: <strong><%= custRs.getInt(1) %></strong></div>
        </div>
        <div class="col-md-4">
            <div class="alert shadow-sm">Stock Value: <strong>₹ <%= valueRs.getDouble(1) %></strong></div>
        </div>
        <%
            } catch (Exception e) {
                e.printStackTrace();
            }
        %>
    </div>

    <!-- Navigation Buttons -->
    <div class="section-heading">Navigation</div>
    <div class="row card-grid">
        <div class="col-md-3"><a href="placeOrder.jsp" class="btn btn-outline-primary w-100">Place New Order</a></div>
        <div class="col-md-3"><a href="addStock.jsp" class="btn btn-outline-secondary w-100">Add Stock</a></div>
        <div class="col-md-3"><a href="adjustStock.jsp" class="btn btn-outline-secondary w-100">Adjust Stock</a></div>
        <div class="col-md-3"><a href="stockLog.jsp" class="btn btn-outline-secondary w-100">Stock Logs</a></div>

        <div class="col-md-3"><a href="salesReport.jsp" class="btn btn-outline-secondary w-100">Sales Report</a></div>
        <div class="col-md-3"><a href="orderHistory.jsp" class="btn btn-outline-secondary w-100">Order History</a></div>
        <div class="col-md-3"><a href="topCustomers.jsp" class="btn btn-outline-secondary w-100">Top Customers</a></div>
        <div class="col-md-3"><a href="productwisesalesreport.jsp" class="btn btn-outline-secondary w-100">Product Sales</a></div>

        <div class="col-md-3"><a href="addcustomer.jsp" class="btn btn-outline-secondary w-100">Add Customer</a></div>
        <div class="col-md-3"><a href="customerList.jsp" class="btn btn-outline-secondary w-100">Customer List</a></div>
        <div class="col-md-3"><a href="stockList.jsp" class="btn btn-outline-secondary w-100">Stock List</a></div>
    </div>

    <!-- Low Stock Section -->
    <div class="low-stock mt-5">
        <div class="section-heading">Low Stock Alerts (Below 10 Units)</div>
        <p class="text-muted small">Last updated: <%= new java.util.Date() %></p>

        <div class="table-responsive">
            <table class="table table-hover table-bordered align-middle">
                <thead class="table-light">
                    <tr>
                        <th>Item Name</th>
                        <th>Quantity</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    try (Connection conn = DBUtil.getConnection();
                         PreparedStatement ps = conn.prepareStatement("SELECT item_name, quantity FROM stock WHERE quantity < 10");
                         ResultSet rs = ps.executeQuery()) {

                        boolean hasLow = false;
                        while (rs.next()) {
                            hasLow = true;
                            int qty = rs.getInt("quantity");
                %>
                    <tr class="<%= qty < 5 ? "table-danger" : "table-warning" %>">
                        <td><%= rs.getString("item_name") %></td>
                        <td class="fw-bold"><%= qty %></td>
                    </tr>
                <%
                        }
                        if (!hasLow) {
                %>
                    <tr>
                        <td colspan="2" class="text-center text-muted">All items are sufficiently stocked.</td>
                    </tr>
                <%
                        }
                    } catch (Exception e) {
                        out.println("<tr><td colspan='2'>Error fetching stock data.</td></tr>");
                        e.printStackTrace();
                    }
                %>
                </tbody>
            </table>
        </div>
    </div>

</div>

<!-- Optional Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
