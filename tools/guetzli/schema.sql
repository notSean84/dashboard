-- Personal Dashboard - Datenbankschema (SQLite-Syntax)
-- Einspielen: sqlite3 db/dashboard.sqlite < db/schema.sql

-- 1) Wunschliste (priorisiert)
CREATE TABLE IF NOT EXISTS wunschliste (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    titel TEXT NOT NULL,
    prioritaet INTEGER NOT NULL DEFAULT 3,   -- 1 = hoch ... 5 = niedrig
    preis REAL,
    link TEXT,
    notiz TEXT,
    erledigt INTEGER NOT NULL DEFAULT 0,     -- 0/1
    erstellt_am TEXT NOT NULL DEFAULT (datetime('now'))
);

-- 2) Familien-Einkaufsliste
CREATE TABLE IF NOT EXISTS einkaufsliste (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    artikel TEXT NOT NULL,
    menge REAL DEFAULT 1,
    einheit TEXT,                             -- z.B. Stk, kg, l
    ort TEXT,                                 -- Einkaufsort
    kategorie TEXT,                           -- z.B. Kuehlregal, Drogerie
    hinzugefuegt_von TEXT,                    -- Familienmitglied
    erledigt INTEGER NOT NULL DEFAULT 0,
    erstellt_am TEXT NOT NULL DEFAULT (datetime('now'))
);

-- 3) Motorrad-Wartung -- Einstellungen (entspricht "Settings"-Sheet)
CREATE TABLE IF NOT EXISTS moto_settings (
    schluessel TEXT PRIMARY KEY,              -- z.B. 'kilometerstand_offset'
    wert TEXT
);

-- 3b) Motorrad-Wartung -- Log (entspricht "Log"-Sheet)
CREATE TABLE IF NOT EXISTS moto_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    datum TEXT NOT NULL,
    kilometerstand INTEGER NOT NULL,
    art TEXT NOT NULL,                        -- z.B. Oelwechsel, Kette, Reifen
    kosten REAL,
    notiz TEXT,
    erstellt_am TEXT NOT NULL DEFAULT (datetime('now'))
);

-- 4) Rekrutierungs-Tracker
CREATE TABLE IF NOT EXISTS rekrutierung_ziele (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    kategorie TEXT NOT NULL,                  -- z.B. Ausdauer, Kraft, Wissen
    bezeichnung TEXT NOT NULL,                -- z.B. "12-Minuten-Lauf"
    zielwert REAL,
    einheit TEXT
);

CREATE TABLE IF NOT EXISTS rekrutierung_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ziel_id INTEGER NOT NULL REFERENCES rekrutierung_ziele(id),
    datum TEXT NOT NULL,
    wert REAL NOT NULL,
    notiz TEXT,
    erstellt_am TEXT NOT NULL DEFAULT (datetime('now'))
);

-- 5) Guetzli-Backen
-- Zutaten haben genau eine feste Einheit (g, kg, ml, Stk., Pck., TL, EL ...),
-- damit der Einkaufszettel pro Zutat sauber aufsummiert werden kann.
CREATE TABLE IF NOT EXISTS guetzli_zutaten (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE COLLATE NOCASE,
    einheit TEXT NOT NULL,                    -- z.B. g, kg, ml, Stk., Pck., TL, EL
    kategorie TEXT                            -- Gruppierung auf dem Einkaufszettel
);

CREATE TABLE IF NOT EXISTS guetzli_sorten (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE COLLATE NOCASE,
    anzahl INTEGER,                           -- Anzahl Kekse pro Rezept (1x)
    rezept_link TEXT,
    notiz TEXT,
    faktor REAL NOT NULL DEFAULT 1,           -- Rezept-Multiplikator (2 = doppelte Menge backen)
    aktiv INTEGER NOT NULL DEFAULT 1,         -- 1 = in diesem Jahr geplant (fliesst in Einkaufszettel)
    erstellt_am TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Zuordnung Sorte <-> Zutat inkl. Menge (in der Einheit der Zutat, pro 1x Rezept)
CREATE TABLE IF NOT EXISTS guetzli_rezept_zutaten (
    sorte_id INTEGER NOT NULL REFERENCES guetzli_sorten(id) ON DELETE CASCADE,
    zutat_id INTEGER NOT NULL REFERENCES guetzli_zutaten(id) ON DELETE RESTRICT,
    menge REAL NOT NULL,
    PRIMARY KEY (sorte_id, zutat_id)
);
