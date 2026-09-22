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
