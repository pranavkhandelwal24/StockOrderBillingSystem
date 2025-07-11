<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*, com.inventory.utils.DBUtil" %>
<!DOCTYPE html>
<html>
<head>
    <title>Place Order</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .item-row { margin-bottom: 15px; }
        .remove-btn { margin-top: 32px; }
    </style>
</head>
<body>
<div class="container mt-4">
    <h2 class="mb-3">Place New Order</h2>
    <a href="dashboard.jsp" class="btn btn-secondary mb-3">← Back</a>

    <form action="placeOrder" method="post">
        <h5>Customer Details</h5>
        <div class="row mb-3">
            <div class="col-md-4">
                <label>Select Customer:</label>
                <select name="customer_email" id="customer_email" class="form-control" onchange="fillCustomerDetails(this.value)" required>
                    <option value="">-- Select --</option>
                    <%
                        try (Connection conn = DBUtil.getConnection();
                             Statement stmt = conn.createStatement();
                             ResultSet rs = stmt.executeQuery("SELECT name, email FROM customers")) {
                            while (rs.next()) {
                                String name = rs.getString("name");
                                String email = rs.getString("email");
                    %>
                        <option value="<%= email %>"><%= name %> (<%= email %>)</option>
                    <%
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                            out.println("<option>Error loading customers</option>");
                        }
                    %>
                </select>
            </div>
            <div class="col-md-4">
                <label>Email:</label>
                <input type="email" name="email" id="email" class="form-control" readonly>
            </div>
            <div class="col-md-4">
                <label>Phone:</label>
                <input type="text" name="phone" id="phone" class="form-control" readonly>
            </div>
            <div class="col-md-12 mt-2">
                <label>Address:</label>
                <textarea name="address" id="address" class="form-control" readonly></textarea>
            </div>
        </div>

        <h5 class="mt-4">Order Items</h5>
        <div id="itemsContainer">
            <div class="row item-row">
                <div class="col-md-4">
                    <label>Item:</label>
                    <select name="item_id" class="form-control item-select" onchange="updatePrice(this)" required>
                        <option value="">-- Select Item --</option>
                        <%
                            try (Connection conn = DBUtil.getConnection();
                                 Statement stmt = conn.createStatement();
                                 ResultSet rs = stmt.executeQuery("SELECT stock_id, item_name FROM stock")) {
                                while (rs.next()) {
                        %>
                            <option value="<%= rs.getInt("stock_id") %>"><%= rs.getString("item_name") %></option>
                        <%
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                                out.println("<option>Error loading items</option>");
                            }
                        %>
                    </select>
                </div>
                <div class="col-md-3">
                    <label>Quantity:</label>
                    <input type="number" name="item_qty" class="form-control" min="1" required>
                </div>
                /*<div class="col-md-3">
                    <label>Price per Unit (₹):</label>
                    <input type="number" step="0.01" name="item_price" class="form-control" required>
                </div>//
                <div class="col-md-2">
                    <button type="button" class="btn btn-danger remove-btn d-none" onclick="removeItem(this)">Remove</button>
                </div>
            </div>
        </div>

        <button type="button" class="btn btn-outline-primary mb-3" onclick="addItem()">+ Add Item</button>
        <button type="submit" class="btn btn-success">Place Order</button>
    </form>
</div>

<!-- JavaScript for AJAX + Dynamic Rows -->
<script>
    function fillCustomerDetails(email) {
        if (!email) return;
        fetch("fetchCustomer?email=" + encodeURIComponent(email))
            .then(res => res.json())
            .then(data => {
                document.getElementById("email").value = data.email;
                document.getElementById("phone").value = data.phone;
                document.getElementById("address").value = data.address;
            })
            .catch(err => {
                alert("Failed to load customer details.");
                console.error(err);
            });
    }

    function addItem() {
        const container = document.getElementById("itemsContainer");
        const row = container.firstElementChild.cloneNode(true);

        row.querySelectorAll("input").forEach(i => i.value = "");
        row.querySelector("select").value = "";
        row.querySelector(".remove-btn").classList.remove("d-none");

        container.appendChild(row);
    }

    function removeItem(btn) {
        const row = btn.closest(".item-row");
        row.remove();
    }

    function updatePrice(select) {
        const stockId = select.value;
        if (!stockId) return;

        fetch("getPrice?stockId=" + stockId)
            .then(res => res.json())
            .then(data => {
                const priceInput = select.closest(".item-row").querySelector("input[name='item_price']");
                priceInput.value = data.price;
            })
            .catch(err => {
                console.error("Price fetch error", err);
            });
    }

</script>
</body>
</html>
