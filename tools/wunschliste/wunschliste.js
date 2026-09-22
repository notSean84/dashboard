const API = "api.php";

async function loadItems() {
    const res = await fetch(API);
    const items = await res.json();
    items.sort((a, b) => a.prioritaet - b.prioritaet);
    renderList(items);
}

function renderList(items) {
    const list = document.getElementById("list");
    list.innerHTML = items.map(item => `
        <li class="prio-${item.prioritaet} ${item.erledigt ? "erledigt" : ""}">
            <span>${item.titel}</span>
            <span class="actions">
                <button onclick="toggleErledigt(${item.id}, ${item.erledigt ? 0 : 1})">
                    ${item.erledigt ? "\u21B6" : "\u2713"}
                </button>
                <button onclick="deleteItem(${item.id})">\u2715</button>
            </span>
        </li>
    `).join("");
}

async function toggleErledigt(id, erledigt) {
    await fetch(API, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ id, erledigt })
    });
    loadItems();
}

async function deleteItem(id) {
    await fetch(`${API}?id=${id}`, { method: "DELETE" });
    loadItems();
}

document.getElementById("add-form").addEventListener("submit", async (e) => {
    e.preventDefault();
    const form = new FormData(e.target);
    await fetch(API, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
            titel: form.get("titel"),
            prioritaet: parseInt(form.get("prioritaet"), 10)
        })
    });
    e.target.reset();
    loadItems();
});

document.addEventListener("DOMContentLoaded", loadItems);
