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
            background-color: #f8f9fa;
        }
        h2 {
            font-weight: 600;
        }
        .btn {
            padding: 12px;
        }
        .card-grid .col-md-3 {
            margin-bottom: 20px;
        }
        .table {
            background-color: #ffffff;
        }
    </style>
</head>
<body>
<div class="container mt-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2>📦 Stock Order Billing Dashboard</h2>
    </div>

    <div class="row card-grid">
        <div class="col-md-3">
            <a href="placeOrder.jsp" class="btn btn-success w-100">🛒 Place New Order</a>
        </div>
        <div class="col-md-3">
            <a href="addStock.jsp" class="btn btn-warning w-100">➕ Add Stock</a>
        </div>
        <div class="col-md-3">
            <a href="adjustStock.jsp" class="btn btn-info w-100">📦 Adjust Stock</a>
        </div>
        <div class="col-md-3">
            <a href="stockLog.jsp" class="btn btn-secondary w-100">📃 Stock Logs</a>
        </div>
        <div class="col-md-3">
            <a href="salesReport.jsp" class="btn btn-dark w-100">📈 Sales Report</a>
        </div>
        <div class="col-md-3">
            <a href="orderHistory.jsp" class="btn btn-primary w-100">🧾 Order History</a>
        </div>
        <div class="col-md-3">
            <a href="topCustomers.jsp" class="btn btn-primary w-100">🏆 Top Customers</a>
        </div>
        <div class="col-md-3">
            <a href="productwisesalesreport.jsp" class="btn btn-dark w-100">📊 Product Sales</a>
        </div>
        <div class="col-md-3">
            <a href="stockList.jsp" class="btn btn-dark w-100">📊 List of Stock</a>
        </div>
    </div>

    <div class="mt-5">
        <h4 class="mb-3">📉 Low Stock Alerts (Below 10 Units)</h4>
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
                %>
                    <tr>
                        <td><%= rs.getString("item_name") %></td>
                        <td class="text-danger fw-bold"><%= rs.getInt("quantity") %></td>
                    </tr>
                <%
                        }
                        if (!hasLow) {
                %>
                    <tr>
                        <td colspan="2" class="text-center text-muted">✅ All items are sufficiently stocked.</td>
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

<!-- Bootstrap JS (optional, if you later want modals/tooltips) -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
