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
%>

<!DOCTYPE html>
<html>
<head>
    <title>Order Bill</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
</head>
<body>
<div class="container mt-4" id="billContent">
    <h2 class="text-center mb-4">Order Invoice</h2>
    <%
        if (orderRs.next()) {
    %>
    <div class="row mb-3">
        <div class="col-md-6">
            <strong>Customer Name:</strong> <%= orderRs.getString("name") %><br>
            <strong>Email:</strong> <%= orderRs.getString("email") %><br>
            <strong>Phone:</strong> <%= orderRs.getString("phone") %><br>
            <strong>Address:</strong> <%= orderRs.getString("address") %>
        </div>
        <div class="col-md-6 text-end">
            <strong>Order ID:</strong> <%= orderId %><br>
            <strong>Order Date:</strong> <%= orderRs.getTimestamp("order_date") %><br>
        </div>
    </div>

    <table class="table table-bordered">
        <thead>
            <tr>
                <th>#</th>
                <th>Item</th>
                <th>Quantity</th>
                <th>Price per Unit</th>
                <th>Total</th>
            </tr>
        </thead>
        <tbody>
            <%
                int count = 1;
                double grandTotal = 0;
                DecimalFormat df = new DecimalFormat("0.00");
                while (itemRs.next()) {
                    int qty = itemRs.getInt("quantity");
                    double price = itemRs.getDouble("price_per_item");
                    double total = qty * price;
                    grandTotal += total;
            %>
            <tr>
                <td><%= count++ %></td>
                <td><%= itemRs.getString("item_name") %></td>
                <td><%= qty %></td>
                <td>₹ <%= df.format(price) %></td>
                <td>₹ <%= df.format(total) %></td>
            </tr>
            <% } %>
            <tr class="table-secondary">
                <td colspan="4" class="text-end"><strong>Total:</strong></td>
                <td><strong>₹ <%= df.format(grandTotal) %></strong></td>
            </tr>
        </tbody>
    </table>
    <% } else { %>
        <div class="alert alert-danger">Order not found.</div>
    <% } %>
</div>

<div class="text-center mt-4">
    <a href="exportPDF?orderId=<%= orderId %>" class="btn btn-outline-danger mt-3">⬇️ Download PDF</a>
    
</div>

<script>
function exportToPDF() {
    const { jsPDF } = window.jspdf;
    const doc = new jsPDF();
    doc.html(document.getElementById("billContent"), {
        callback: function (pdf) {
            pdf.save("invoice_<%= orderId %>.pdf");
        },
        x: 10,
        y: 10
    });
}
</script>
</body>
</html>
