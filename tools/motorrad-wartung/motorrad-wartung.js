const API_LOG = "api_log.php";
const API_TYPEN = "api_typen.php";
const API_SETTINGS = "api_settings.php";
const BALD_FAELLIG_SCHWELLE = 300; // KM, ab wann "bald faellig" statt "OK" angezeigt wird

let typen = [];
let eintraege = [];
let aktuellerKm = 0;

async function loadAll() {
    const [typenRes, logRes, settingsRes] = await Promise.all([
        fetch(API_TYPEN).then(r => r.json()),
        fetch(API_LOG).then(r => r.json()),
        fetch(`${API_SETTINGS}?schluessel=aktueller_kilometerstand`).then(r => r.json())
    ]);
    typen = typenRes;
    eintraege = logRes;
    aktuellerKm = parseInt(settingsRes.wert, 10) || 0;
    document.getElementById("aktueller-km").value = aktuellerKm || "";
    populateTypSelect();
    renderOverview();
}

function letzterServiceFuer(bezeichnung) {
    const treffer = eintraege
        .filter(e => e.art === bezeichnung)
        .sort((a, b) => b.kilometerstand - a.kilometerstand);
    return treffer[0] || null;
}

function renderOverview() {
    const body = document.getElementById("overview-body");

    if (typen.length === 0) {
        body.innerHTML = `<tr><td colspan="7" class="empty-hint">Noch keine Service-Typen erfasst. Lege zuerst einen unter "Service-Typen" an.</td></tr>`;
        return;
    }

    const zeilen = typen.map(typ => {
        const letzter = letzterServiceFuer(typ.bezeichnung);
        const kmLetzterService = letzter ? letzter.kilometerstand : 0;
        const restKm = typ.intervall_km - (aktuellerKm - kmLetzterService);

        let statusClass = "status-ok";
        let statusText = "OK";
        if (restKm <= 0) {
            statusClass = "status-faellig";
            statusText = "Faellig";
        } else if (restKm <= BALD_FAELLIG_SCHWELLE) {
            statusClass = "status-bald";
            statusText = "Bald faellig";
        }

        return { typ, letzter, restKm, statusClass, statusText };
    });

    zeilen.sort((a, b) => a.restKm - b.restKm);

    body.innerHTML = zeilen.map(({ typ, letzter, restKm, statusClass, statusText }) => `
        <tr>
            <td data-label="Service-Typ">${typ.bezeichnung}</td>
            <td data-label="Intervall">${typ.intervall_km} km</td>
            <td data-label="Letztes Datum">${letzter ? letzter.datum : "-"}</td>
            <td data-label="KM letzter Service">${letzter ? letzter.kilometerstand : "-"}</td>
            <td data-label="Rest-KM">${letzter ? restKm : "-"}</td>
            <td data-label="Status"><span class="status ${statusClass}">${letzter ? statusText : "Kein Service erfasst"}</span></td>
            <td data-label="CHF">${letzter && letzter.kosten ? letzter.kosten : "-"}</td>
        </tr>
    `).join("");
}

function populateTypSelect() {
    const select = document.getElementById("service-typ");
    const aktuellerWert = select.value;
    select.innerHTML = typen.map(t => `<option value="${t.bezeichnung}">${t.bezeichnung}</option>`).join("");
    if (aktuellerWert) select.value = aktuellerWert;
}

// --- Modal-Steuerung ---
document.querySelectorAll("[data-close]").forEach(btn => {
    btn.addEventListener("click", () => closeModal(btn.dataset.close));
});

function openModal(id) {
    document.getElementById(id).classList.add("open");
}
function closeModal(id) {
    document.getElementById(id).classList.remove("open");
}

// --- Neuer Service / Service bearbeiten ---
document.getElementById("btn-neuer-service").addEventListener("click", () => {
    document.getElementById("service-modal-title").textContent = "Neuer Service";
    const form = document.getElementById("service-form");
    form.reset();
    form.elements["id"].value = "";
    document.getElementById("service-datum").value = new Date().toISOString().slice(0, 10);
    openModal("modal-service");
});

document.getElementById("service-form").addEventListener("submit", async (e) => {
    e.preventDefault();
    const form = new FormData(e.target);
    const id = form.get("id");
    const payload = {
        datum: form.get("datum"),
        kilometerstand: parseInt(form.get("kilometerstand"), 10),
        art: form.get("art"),
        kosten: form.get("kosten") ? parseFloat(form.get("kosten")) : null,
        notiz: form.get("notiz") || null
    };

    if (id) {
        payload.id = parseInt(id, 10);
        await fetch(API_LOG, { method: "PUT", headers: { "Content-Type": "application/json" }, body: JSON.stringify(payload) });
    } else {
        await fetch(API_LOG, { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(payload) });
    }

    closeModal("modal-service");
    await loadAll();
});

// --- Verlauf ---
document.getElementById("btn-verlauf").addEventListener("click", () => {
    renderVerlauf();
    openModal("modal-verlauf");
});

function renderVerlauf() {
    const liste = document.getElementById("verlauf-list");

    if (eintraege.length === 0) {
        liste.innerHTML = `<li class="empty-hint">Noch keine Services erfasst.</li>`;
        return;
    }

    const sortiert = [...eintraege].sort((a, b) => b.kilometerstand - a.kilometerstand);

    liste.innerHTML = sortiert.map(eintrag => {
        const typ = typen.find(t => t.bezeichnung === eintrag.art);
        const naechsterService = typ ? eintrag.kilometerstand + typ.intervall_km : null;

        return `
            <li>
                <span>
                    <strong>${eintrag.art}</strong> &middot; ${eintrag.datum} &middot; ${eintrag.kilometerstand} km
                    ${eintrag.kosten ? ` &middot; CHF ${eintrag.kosten}` : ""}
                    ${eintrag.notiz ? `<br><span style="color:var(--text-muted);">${eintrag.notiz}</span>` : ""}
                    ${naechsterService ? `<br><span style="color:var(--text-muted);">Naechster Service ab ${naechsterService} km</span>` : ""}
                </span>
                <span class="actions">
                    <button onclick="editLogEntry(${eintrag.id})" title="Bearbeiten">&#9998;</button>
                    <button onclick="deleteLogEntry(${eintrag.id})" title="Loeschen">&#10005;</button>
                </span>
            </li>
        `;
    }).join("");
}

function editLogEntry(id) {
    const eintrag = eintraege.find(e => e.id === id);
    if (!eintrag) return;

    closeModal("modal-verlauf");
    document.getElementById("service-modal-title").textContent = "Service bearbeiten";

    const form = document.getElementById("service-form");
    form.elements["id"].value = eintrag.id;
    form.elements["datum"].value = eintrag.datum;
    form.elements["kilometerstand"].value = eintrag.kilometerstand;
    form.elements["art"].value = eintrag.art;
    form.elements["kosten"].value = eintrag.kosten || "";
    form.elements["notiz"].value = eintrag.notiz || "";

    openModal("modal-service");
}

async function deleteLogEntry(id) {
    if (!confirm("Diesen Service-Eintrag wirklich loeschen?")) return;
    await fetch(`${API_LOG}?id=${id}`, { method: "DELETE" });
    await loadAll();
    renderVerlauf();
}

// --- Service-Typen ---
document.getElementById("btn-typen").addEventListener("click", () => {
    renderTypenListe();
    openModal("modal-typen");
});

document.getElementById("typ-form").addEventListener("submit", async (e) => {
    e.preventDefault();
    const form = new FormData(e.target);
    await fetch(API_TYPEN, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
            bezeichnung: form.get("bezeichnung"),
            intervall_km: parseInt(form.get("intervall_km"), 10)
        })
    });
    e.target.reset();
    await loadAll();
    renderTypenListe();
});

function renderTypenListe() {
    const liste = document.getElementById("typ-list");

    if (typen.length === 0) {
        liste.innerHTML = `<li class="empty-hint">Noch keine Service-Typen erfasst.</li>`;
        return;
    }

    liste.innerHTML = typen.map(t => `
        <li>
            <span class="typ-edit-inputs">
                <input type="text" value="${t.bezeichnung}" data-id="${t.id}" data-field="bezeichnung">
                <input type="number" value="${t.intervall_km}" data-id="${t.id}" data-field="intervall_km">
            </span>
            <span class="actions">
                <button onclick="saveTyp(${t.id})" title="Speichern">&#128190;</button>
                <button onclick="deleteTyp(${t.id})" title="Loeschen">&#10005;</button>
            </span>
        </li>
    `).join("");
}

async function saveTyp(id) {
    const bezInput = document.querySelector(`input[data-id="${id}"][data-field="bezeichnung"]`);
    const intInput = document.querySelector(`input[data-id="${id}"][data-field="intervall_km"]`);

    await fetch(API_TYPEN, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
            id,
            bezeichnung: bezInput.value,
            intervall_km: parseInt(intInput.value, 10)
        })
    });

    await loadAll();
    renderTypenListe();
}

async function deleteTyp(id) {
    if (!confirm("Diesen Service-Typ wirklich loeschen? Vergangene Eintraege bleiben erhalten, erscheinen aber nicht mehr in der Uebersicht.")) return;
    await fetch(`${API_TYPEN}?id=${id}`, { method: "DELETE" });
    await loadAll();
    renderTypenListe();
}

// --- Aktueller Kilometerstand ---
document.getElementById("btn-km-speichern").addEventListener("click", async () => {
    const wert = document.getElementById("aktueller-km").value;
    await fetch(API_SETTINGS, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ schluessel: "aktueller_kilometerstand", wert })
    });
    await loadAll();
});

document.addEventListener("DOMContentLoaded", loadAll);
