// Zentrale Liste der Tools. Neues Tool = neuer Eintrag + neuer Ordner in /tools.
const TOOLS = [
    {
        titel: "Einkaufsliste",
        beschreibung: "Familien-Einkaufsliste mit Menge, Ort etc.",
        url: "tools/einkaufsliste/index.html",
        image: "tools/einkaufsliste/img.jpg"
    },
    {
        titel: "Rekrutierung",
        beschreibung: "Fortschritt fuer die Vorbereitung tracken",
        url: "tools/rekrutierung-tracker/index.html",
        image: "tools/rekrutierung-tracker/img.png"
    },
    {
        titel: "Wunschliste",
        beschreibung: "Dinge, die ich kaufen moechte, priorisiert",
        url: "tools/wunschliste/index.html",
        image: "tools/wunschliste/img.jpg"
    },
    {
        titel: "Motorrad-Wartung",
        beschreibung: "Wartungslog und Kilometerstand-Tracking",
        url: "tools/motorrad-wartung/index.html",
        image: "tools/motorrad-wartung/img.png"
    }
];

function renderTiles() {
    const grid = document.getElementById("tile-grid");
    grid.innerHTML = TOOLS.map(tool => `
        <a class="tile" href="${tool.url}">
            <img class="tile-img" src="${tool.image}" alt="${tool.titel}">
            <div class="tile-content">
                <h2>${tool.titel}</h2>
                <p>${tool.beschreibung}</p>
            </div>
        </a>
    `).join("");
}

document.addEventListener("DOMContentLoaded", renderTiles);
