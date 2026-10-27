const API = "api.php";
const EINHEITEN = ["g", "kg", "ml", "l", "Stk.", "Pck.", "TL", "EL", "Fläschchen"];
const HAKEN_KEY = "guetzli_einkauf_haken";

let sorten = [];
let zutaten = [];
let einkauf = [];
let formZeilen = [];   // Zutaten-Zeilen im Dialog: [{ zutat_id, menge }]
let bearbeiteId = null;

// ------------------------------------------------------------------ Helfer
async function api(resource, method = "GET", body = null, query = "") {
    const res = await fetch(`${API}?resource=${resource}${query}`, {
        method,
        headers: body ? { "Content-Type": "application/json" } : {},
        body: body ? JSON.stringify(body) : undefined
    });
    const data = await res.json();
    if (!res.ok) {
        alert(data.error || "Fehler");
        throw new Error(data.error || res.status);
    }
    return data;
}

function esc(s) {
    return String(s ?? "").replace(/[&<>"']/g, c => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));
}

function zahl(n) {
    return String(Math.round(n * 100) / 100).replace(".", ",");
}

// Anzeige: 1200 g -> 1,2 kg, 1500 ml -> 1,5 l (nur Darstellung, DB bleibt unveraendert)
function formatMenge(menge, einheit) {
    if (einheit === "g" && menge >= 1000) return `${zahl(menge / 1000)} kg`;
    if (einheit === "ml" && menge >= 1000) return `${zahl(menge / 1000)} l`;
    return `${zahl(menge)} ${einheit}`;
}

function linkUrl(l) {
    return /^https?:\/\//i.test(l) ? l : `https://${l}`;
}

function ladeHaken() {
    try { return new Set(JSON.parse(localStorage.getItem(HAKEN_KEY) || "[]")); }
    catch { return new Set(); }
}
function speichereHaken(set) {
    try { localStorage.setItem(HAKEN_KEY, JSON.stringify([...set])); } catch { /* ignorieren */ }
}

// ------------------------------------------------------------------ Laden
async function ladeAlles() {
    [sorten, zutaten, einkauf] = await Promise.all([
        api("sorten"), api("zutaten"), api("einkauf")
    ]);
    renderStats();
    renderSorten();
    renderEinkauf();
    renderZutaten();
    renderDatalists();
}

// ------------------------------------------------------------------ Render
function renderStats() {
    const aktive = sorten.filter(s => s.aktiv);
    const kekse = aktive.reduce((sum, s) => sum + (s.anzahl || 0) * s.faktor, 0);
    document.getElementById("stats").textContent =
        `${aktive.length} von ${sorten.length} Sorten geplant · ca. ${Math.round(kekse)} Kekse`;
}

function renderSorten() {
    const ul = document.getElementById("sorten-liste");
    if (!sorten.length) {
        ul.innerHTML = `<li class="leer">Noch keine Sorten. Lege oben die erste an.</li>`;
        return;
    }
    ul.innerHTML = sorten.map(s => {
        const kekse = s.anzahl ? `${Math.round(s.anzahl * s.faktor)} Kekse` : "Anzahl offen";
        const link = s.rezept_link
            ? ` · <a href="${esc(linkUrl(s.rezept_link))}" target="_blank" rel="noopener">Rezept</a>` : "";
        const zutatenListe = s.zutaten.length
            ? `<details><summary>${s.zutaten.length} Zutaten</summary><ul>${
                s.zutaten.map(z => `<li>${esc(z.name)}: ${esc(formatMenge(z.menge * s.faktor, z.einheit))}</li>`).join("")
              }</ul></details>`
            : `<div class="meta">Noch keine Zutaten erfasst</div>`;
        return `
        <li class="karte ${s.aktiv ? "" : "inaktiv"}">
            <div class="karte-kopf">
                <div>
                    <div class="karte-titel">${esc(s.name)}</div>
                    <div class="meta">${kekse}${link}</div>
                </div>
                <div class="karte-aktionen">
                    <label><input type="checkbox" ${s.aktiv ? "checked" : ""} onchange="setAktiv(${s.id}, this.checked)"> geplant</label>
                    <label>x <input class="faktor-input" type="number" min="0.25" step="0.25" value="${s.faktor}" onchange="setFaktor(${s.id}, this.value)"></label>
                    <button class="klein" onclick="oeffneDialog(${s.id})" title="Bearbeiten">\u270E</button>
                    <button class="klein" onclick="loescheSorte(${s.id})" title="Loeschen">\u2715</button>
                </div>
            </div>
            ${s.notiz ? `<div class="notiz">${esc(s.notiz)}</div>` : ""}
            ${zutatenListe}
        </li>`;
    }).join("");
}

function renderEinkauf() {
    const box = document.getElementById("einkauf-liste");
    if (!einkauf.length) {
        box.innerHTML = `<p class="leer">Nichts zu kaufen. Aktiviere Sorten mit Zutaten.</p>`;
        return;
    }
    const haken = ladeHaken();
    const gruppen = {};
    einkauf.forEach(e => { (gruppen[e.kategorie || "Sonstiges"] ??= []).push(e); });
    box.innerHTML = Object.keys(gruppen).sort((a, b) => a.localeCompare(b, "de")).map(k => `
        <div class="gruppe">
            <h3>${esc(k)}</h3>
            ${gruppen[k].map(e => `
                <div class="einkauf-zeile ${haken.has(e.id) ? "abgehakt" : ""}" onclick="toggleHaken(${e.id})">
                    <input type="checkbox" ${haken.has(e.id) ? "checked" : ""} tabindex="-1">
                    <span>${esc(e.name)}</span>
                    <span class="menge">${esc(formatMenge(e.menge, e.einheit))}</span>
                </div>`).join("")}
        </div>`).join("");
}

function renderZutaten() {
    const tb = document.getElementById("zutaten-tabelle");
    tb.innerHTML = zutaten.map(z => `
        <tr>
            <td>${esc(z.name)}</td>
            <td>${esc(z.einheit)}</td>
            <td>${esc(z.kategorie || "")}</td>
            <td>${z.verwendet}</td>
            <td style="text-align:right;white-space:nowrap;">
                <button class="klein" onclick="bearbeiteZutat(${z.id})" title="Bearbeiten">\u270E</button>
                <button class="klein" onclick="loescheZutat(${z.id})" title="Loeschen">\u2715</button>
            </td>
        </tr>`).join("");
}

function renderDatalists() {
    const einh = new Set([...EINHEITEN, ...zutaten.map(z => z.einheit)]);
    document.getElementById("einheiten").innerHTML = [...einh].map(e => `<option value="${esc(e)}">`).join("");
    const kats = new Set(zutaten.map(z => z.kategorie).filter(Boolean));
    document.getElementById("kategorien").innerHTML = [...kats].map(k => `<option value="${esc(k)}">`).join("");
}

// ------------------------------------------------------------------ Sorten-Aktionen
async function setAktiv(id, aktiv) {
    await api("sorten", "PUT", { id, aktiv: aktiv ? 1 : 0 });
    ladeAlles();
}

async function setFaktor(id, wert) {
    const faktor = parseFloat(wert);
    if (!(faktor > 0)) return ladeAlles();
    await api("sorten", "PUT", { id, faktor });
    ladeAlles();
}

async function loescheSorte(id) {
    const s = sorten.find(x => x.id === id);
    if (!confirm(`Sorte "${s.name}" wirklich loeschen?`)) return;
    await api("sorten", "DELETE", null, `&id=${id}`);
    ladeAlles();
}

// ------------------------------------------------------------------ Dialog
const dialog = document.getElementById("sorte-dialog");

function oeffneDialog(id = null) {
    bearbeiteId = id;
    const s = id ? sorten.find(x => x.id === id) : null;
    document.getElementById("dialog-titel").textContent = s ? "Sorte bearbeiten" : "Neue Sorte";
    document.getElementById("f-name").value = s?.name ?? "";
    document.getElementById("f-anzahl").value = s?.anzahl ?? "";
    document.getElementById("f-faktor").value = s?.faktor ?? 1;
    document.getElementById("f-link").value = s?.rezept_link ?? "";
    document.getElementById("f-notiz").value = s?.notiz ?? "";
    formZeilen = s ? s.zutaten.map(z => ({ zutat_id: z.zutat_id, menge: z.menge })) : [{ zutat_id: "", menge: "" }];
    document.getElementById("neue-zutat").classList.remove("offen");
    renderZeilen();
    dialog.showModal();
}

function renderZeilen() {
    const box = document.getElementById("zutat-zeilen");
    box.innerHTML = formZeilen.map((zeile, i) => {
        const gewaehlt = zutaten.find(z => z.id === Number(zeile.zutat_id));
        const belegt = new Set(formZeilen.filter((_, j) => j !== i).map(r => Number(r.zutat_id)));
        const optionen = zutaten.map(z =>
            `<option value="${z.id}" ${z.id === Number(zeile.zutat_id) ? "selected" : ""} ${belegt.has(z.id) ? "disabled" : ""}>${esc(z.name)}</option>`
        ).join("");
        return `
        <div class="zutat-zeile">
            <select data-i="${i}" data-feld="zutat_id">
                <option value="">Zutat waehlen...</option>${optionen}
            </select>
            <input type="number" min="0" step="any" placeholder="Menge" data-i="${i}" data-feld="menge" value="${esc(zeile.menge)}">
            <span class="einheit">${esc(gewaehlt?.einheit ?? "")}</span>
            <button type="button" class="klein" data-entfernen="${i}">\u2715</button>
        </div>`;
    }).join("");
}

document.getElementById("zutat-zeilen").addEventListener("input", e => {
    const i = e.target.dataset.i;
    if (i === undefined) return;
    formZeilen[i][e.target.dataset.feld] = e.target.value;
    if (e.target.dataset.feld === "zutat_id") renderZeilen();
});

document.getElementById("zutat-zeilen").addEventListener("click", e => {
    const i = e.target.dataset.entfernen;
    if (i === undefined) return;
    formZeilen.splice(i, 1);
    renderZeilen();
});

document.getElementById("btn-zeile").addEventListener("click", () => {
    formZeilen.push({ zutat_id: "", menge: "" });
    renderZeilen();
});

document.getElementById("btn-neue-zutat").addEventListener("click", () => {
    document.getElementById("neue-zutat").classList.toggle("offen");
});

// Neue Zutat direkt im Dialog anlegen und in der naechsten freien Zeile auswaehlen
document.getElementById("btn-nz-speichern").addEventListener("click", async () => {
    const box = document.getElementById("neue-zutat");
    const name = box.querySelector('[name="nz-name"]').value.trim();
    const einheit = box.querySelector('[name="nz-einheit"]').value.trim();
    const kategorie = box.querySelector('[name="nz-kategorie"]').value.trim();
    if (!name || !einheit) return alert("Name und Einheit sind Pflicht.");

    const { id } = await api("zutaten", "POST", { name, einheit, kategorie });
    zutaten = await api("zutaten");
    renderDatalists();
    renderZutaten();

    const leere = formZeilen.find(z => !z.zutat_id);
    if (leere) leere.zutat_id = id; else formZeilen.push({ zutat_id: id, menge: "" });
    renderZeilen();
    box.querySelectorAll("input").forEach(i => i.value = "");
    box.classList.remove("offen");
});

document.getElementById("btn-abbrechen").addEventListener("click", () => dialog.close());
document.getElementById("btn-neue-sorte").addEventListener("click", () => oeffneDialog());

document.getElementById("sorte-form").addEventListener("submit", async e => {
    e.preventDefault();
    const payload = {
        name: document.getElementById("f-name").value,
        anzahl: document.getElementById("f-anzahl").value,
        faktor: parseFloat(document.getElementById("f-faktor").value) || 1,
        rezept_link: document.getElementById("f-link").value,
        notiz: document.getElementById("f-notiz").value,
        zutaten: formZeilen
            .filter(z => z.zutat_id && parseFloat(z.menge) > 0)
            .map(z => ({ zutat_id: Number(z.zutat_id), menge: parseFloat(z.menge) }))
    };
    if (bearbeiteId) await api("sorten", "PUT", { id: bearbeiteId, ...payload });
    else await api("sorten", "POST", payload);
    dialog.close();
    ladeAlles();
});

// ------------------------------------------------------------------ Zutaten-Tab
document.getElementById("zutat-form").addEventListener("submit", async e => {
    e.preventDefault();
    const f = new FormData(e.target);
    await api("zutaten", "POST", { name: f.get("name"), einheit: f.get("einheit"), kategorie: f.get("kategorie") });
    e.target.reset();
    ladeAlles();
});

async function bearbeiteZutat(id) {
    const z = zutaten.find(x => x.id === id);
    const name = prompt("Name:", z.name);
    if (name === null) return;
    const einheit = prompt("Einheit (Achtung: Mengen in Rezepten bleiben unveraendert):", z.einheit);
    if (einheit === null) return;
    const kategorie = prompt("Kategorie:", z.kategorie ?? "");
    if (kategorie === null) return;
    await api("zutaten", "PUT", { id, name, einheit, kategorie });
    ladeAlles();
}

async function loescheZutat(id) {
    const z = zutaten.find(x => x.id === id);
    if (!confirm(`Zutat "${z.name}" wirklich loeschen?`)) return;
    await api("zutaten", "DELETE", null, `&id=${id}`);
    ladeAlles();
}

// ------------------------------------------------------------------ Einkaufszettel
function toggleHaken(id) {
    const haken = ladeHaken();
    haken.has(id) ? haken.delete(id) : haken.add(id);
    speichereHaken(haken);
    renderEinkauf();
}

document.getElementById("btn-reset-haken").addEventListener("click", () => {
    speichereHaken(new Set());
    renderEinkauf();
});

document.getElementById("btn-drucken").addEventListener("click", () => window.print());

document.getElementById("btn-kopieren").addEventListener("click", async () => {
    const haken = ladeHaken();
    const text = einkauf
        .filter(e => !haken.has(e.id))
        .map(e => `- ${formatMenge(e.menge, e.einheit)} ${e.name}`)
        .join("\n");
    try {
        await navigator.clipboard.writeText(text);
        alert("Einkaufszettel kopiert (ohne abgehakte Artikel).");
    } catch {
        prompt("Zum Kopieren markieren:", text);
    }
});

// ------------------------------------------------------------------ Tabs
document.querySelectorAll(".tabs button").forEach(btn => {
    btn.addEventListener("click", () => {
        document.querySelectorAll(".tabs button").forEach(b => b.classList.toggle("active", b === btn));
        document.querySelectorAll(".panel").forEach(p => p.classList.toggle("active", p.id === `panel-${btn.dataset.tab}`));
    });
});

document.addEventListener("DOMContentLoaded", ladeAlles);
