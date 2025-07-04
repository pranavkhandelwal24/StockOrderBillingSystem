let rowIndex = 0;
window.stockOptions = "";

function addItemRow() {
    const container = document.getElementById("itemsContainer");

    const row = document.createElement("div");
    row.className = "row mt-2 align-items-end";
    row.innerHTML = `
        <div class="col-md-6">
            <label>Item Name:</label>
            <select name="item_id" class="form-control" required>
                ${window.stockOptions || '<option>Loading...</option>'}
            </select>
        </div>
        <div class="col-md-4">
            <label>Quantity:</label>
            <input type="number" name="item_qty" class="form-control" min="1" required>
        </div>
        <div class="col-md-2">
            <button type="button" class="btn btn-danger" onclick="this.closest('.row').remove()">🗑️</button>
        </div>
    `;
    container.appendChild(row);
}

function fetchCustomer() {
    const email = document.getElementById("email").value.trim();
    if (!email) return;

    fetch("fetchCustomer?email=" + encodeURIComponent(email))
        .then(res => res.json())
        .then(data => {
            if (data.found) {
                document.getElementById("name").value = data.name;
                document.getElementById("phone").value = data.phone;
                document.getElementById("address").value = data.address;
            }
        })
        .catch(err => console.error("Customer fetch error:", err));
}

window.onload = () => {
    fetch("fetchStockOptions")
        .then(res => res.text())
        .then(options => {
            window.stockOptions = options;
            addItemRow(); // Add first item row after options load
        })
        .catch(err => {
            console.error("Error loading stock options:", err);
            alert("⚠️ Failed to load item list. Please try again.");
        });
};
