// Zentrale Liste der Tools. Neues Tool = neuer Eintrag + neuer Ordner in /tools.
const TOOLS = [
    {
        titel: "Wunschliste",
        beschreibung: "Dinge, die ich kaufen moechte, priorisiert",
        icon: "\u2B50",
        url: "tools/wunschliste/index.html"
    },
    {
        titel: "Einkaufsliste",
        beschreibung: "Familien-Einkaufsliste mit Menge, Ort etc.",
        icon: "\uD83D\uDED2",
        url: "tools/einkaufsliste/index.html"
    },
    {
        titel: "Motorrad-Wartung",
        beschreibung: "Wartungslog und Kilometerstand-Tracking",
        icon: "\uD83C\uDFCD\uFE0F",
        url: "tools/motorrad-wartung/index.html"
    },
    {
        titel: "Rekrutierung",
        beschreibung: "Fortschritt fuer die Vorbereitung tracken",
        icon: "\uD83D\uDCAA",
        url: "tools/rekrutierung-tracker/index.html"
    }
];

function renderTiles() {
    const grid = document.getElementById("tile-grid");
    grid.innerHTML = TOOLS.map(tool => `
        <a class="tile" href="${tool.url}">
            <span class="icon">${tool.icon}</span>
            <h2>${tool.titel}</h2>
            <p>${tool.beschreibung}</p>
        </a>
    `).join("");
}

document.addEventListener("DOMContentLoaded", renderTiles);
