# Mein Dashboard

## Struktur
```
personal-dashboard/
├── index.html              # Startseite mit Kacheln
├── css/style.css           # Globale Styles
├── js/dashboard.js         # Kachel-Liste + Rendering
├── api/config.php          # DB-Verbindung (SQLite Standard), Helper-Funktionen
├── db/schema.sql           # Alle Tabellen fuer alle Tools
└── tools/
    ├── wunschliste/        # FERTIG - Referenz-Implementierung
    │   ├── index.html
    │   ├── wunschliste.js
    │   └── api.php
    ├── einkaufsliste/       # Platzhalter
    ├── motorrad-wartung/    # Platzhalter
    └── rekrutierung-tracker/# Platzhalter
```

## Prinzip
Jedes Tool ist ein eigener, in sich geschlossener Ordner unter `tools/`:
- `index.html` - Oberflaeche des Tools
- `<name>.js` - Frontend-Logik, spricht die eigene `api.php` per fetch() an
- `api.php` - eigenes REST-Mini-Backend (GET/POST/PUT/DELETE), nutzt die zentrale
  DB-Verbindung aus `api/config.php`

Alle Tools teilen sich `css/style.css` (Kachel-Look) und eine einzige Datenbank
(`db/dashboard.sqlite`), aber jedes Tool hat seine eigene(n) Tabelle(n).
Ein neues Tool auf dem Dashboard = ein Eintrag in `js/dashboard.js` + ein neuer
Ordner nach diesem Muster.

## Setup
1. Lokalen PHP-Server starten:
   ```
   cd personal-dashboard
   php -S localhost:8000
   ```
2. Datenbank einmalig anlegen:
   ```
   sqlite3 db/dashboard.sqlite < db/schema.sql
   ```
3. Im Browser: http://localhost:8000

## Naechste Schritte
1. Wunschliste im Browser testen (Tabelle ist bereits im Schema enthalten).
2. Einkaufsliste nach dem Wunschliste-Muster bauen (Tabelle `einkaufsliste`
   ist im Schema bereits vorbereitet: Menge, Einheit, Ort, Kategorie, Person).
3. Motorrad-Wartung bauen. Zwei Tabellen sind vorbereitet:
   `moto_settings` (Kilometerstand-Offset etc.) und `moto_log` (einzelne
   Wartungseintraege) - entspricht dem Aufbau des bisherigen Excel-Trackers.
4. Rekrutierung-Tracker bauen: `rekrutierung_ziele` (welche Kategorien/Ziele)
   + `rekrutierung_log` (einzelne Messwerte pro Datum).
5. Weitere Tools spaeter einfach nach demselben Muster ergaenzen.
