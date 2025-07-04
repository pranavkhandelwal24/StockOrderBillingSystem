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
    <h2>➕ Adjust Stock</h2>
    <a href="dashboard.jsp" class="btn btn-secondary mb-3">← Back to Dashboard</a>

    <form action="adjustStock" method="post" class="mt-3">
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

        <div class="mb-3">
            <label>Adjustment Type:</label>
            <select name="adjustment_type" class="form-control" required>
                <option value="restock">Restock (+)</option>
                <option value="return">Return (-)</option>
                <option value="correction">Correction (+/-)</option>
            </select>
        </div>

        <div class="mb-3">
            <label>Quantity Change:</label>
            <input type="number" name="quantity_change" class="form-control" required>
        </div>

        <div class="mb-3">
            <label>Reason:</label>
            <textarea name="reason" class="form-control" required></textarea>
        </div>

        <button type="submit" class="btn btn-primary">Submit Adjustment</button>
        <a href="dashboard.jsp" class="btn btn-secondary">Back</a>
    </form>
</div>
</body>
</html>
