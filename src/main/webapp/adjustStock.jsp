<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, com.inventory.utils.DBUtil" %>
<!DOCTYPE html>
<html>
<head>
    <title>Adjust Stock</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-4">
    <h2> Adjust Stock Quantity</h2>
    <a href="dashboard.jsp" class="btn btn-secondary mb-3">← Back to Dashboard</a>

    <form action="adjustStock" method="post" class="mt-3">
        <!-- Select Stock Item -->
        <div class="mb-3">
            <label>Select Item:</label>
            <select name="stock_id" class="form-control" required>
                <option value="">-- Choose an item --</option>
                <%
                    try (Connection conn = DBUtil.getConnection();
                         PreparedStatement ps = conn.prepareStatement("SELECT stock_id, item_name FROM stock");
                         ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                %>
                    <option value="<%= rs.getInt("stock_id") %>"><%= rs.getString("item_name") %></option>
                <%
                        }
                    } catch (Exception e) {
                        out.println("<option>Error loading stock</option>");
                        e.printStackTrace();
                    }
                %>
            </select>
        </div>

        <!-- Adjustment Type -->
        <div class="mb-3">
            <label>Adjustment Type:</label>
            <select name="adjustment_type" class="form-control" required>
                <option value="">-- Select Adjustment Type --</option>
                <option value="restock">+ Add Stock (Restock)</option>
                <option value="return">- Subtract Stock (Customer Return)</option>
                <option value="correction">⚠️ Correct Stock (Manual Fix)</option>
            </select>
            <small class="text-muted">
                <ul>
                    <li><b>Restock:</b> Add new inventory received.</li>
                    <li><b>Return:</b> Remove stock returned by customer or damaged.</li>
                    <li><b>Correction:</b> Fix quantity if stock was entered incorrectly (can be + or -).</li>
                </ul>
            </small>
        </div>

        <!-- Quantity -->
        <div class="mb-3">
            <label>Quantity Change:</label>
            <input type="number" name="quantity_change" class="form-control" required placeholder="Enter quantity (e.g., 10 or -5)">
            <small class="text-muted">Enter positive or negative quantity depending on correction type.</small>
        </div>

        <!-- Reason -->
        <div class="mb-3">
            <label>Reason / Note:</label>
            <textarea name="reason" class="form-control" rows="3" required placeholder="Enter reason for adjustment"></textarea>
        </div>

        <!-- Submit -->
        <button type="submit" class="btn btn-primary">✅ Submit Adjustment</button>
        <a href="dashboard.jsp" class="btn btn-secondary">Cancel</a>
    </form>
</div>
</body>
</html>
