-- Guetzli-Backen: Schema + Startdaten fuer MySQL (phpMyAdmin -> Datenbank waehlen -> Tab "SQL" -> einfuegen)
-- Mehrfaches Ausfuehren ist ungefaehrlich (IF NOT EXISTS / INSERT IGNORE).

CREATE TABLE IF NOT EXISTS guetzli_zutaten (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120) NOT NULL UNIQUE,
    einheit VARCHAR(30) NOT NULL,             -- z.B. g, kg, ml, Stk., Pck., TL, EL
    kategorie VARCHAR(60) NULL                -- Gruppierung auf dem Einkaufszettel
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS guetzli_sorten (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120) NOT NULL UNIQUE,
    anzahl INT NULL,                          -- Anzahl Kekse pro Rezept (1x)
    rezept_link VARCHAR(500) NULL,
    notiz TEXT NULL,
    faktor DECIMAL(6,2) NOT NULL DEFAULT 1,   -- Rezept-Multiplikator (2 = doppelte Menge backen)
    aktiv TINYINT(1) NOT NULL DEFAULT 1,      -- 1 = in diesem Jahr geplant
    erstellt_am DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS guetzli_rezept_zutaten (
    sorte_id INT NOT NULL,
    zutat_id INT NOT NULL,
    menge DECIMAL(10,2) NOT NULL,             -- in der Einheit der Zutat, pro 1x Rezept
    PRIMARY KEY (sorte_id, zutat_id),
    FOREIGN KEY (sorte_id) REFERENCES guetzli_sorten(id) ON DELETE CASCADE,
    FOREIGN KEY (zutat_id) REFERENCES guetzli_zutaten(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Seed: Guetzli 2025 (aus Guetzli2025.xlsx). Mehrfaches Ausfuehren ist ungefährlich (INSERT IGNORE).

-- Zutaten
INSERT IGNORE INTO guetzli_zutaten (name, einheit, kategorie) VALUES ('Butter', 'g', 'Milchprodukte & Eier');
INSERT IGNORE INTO guetzli_zutaten (name, einheit, kategorie) VALUES ('Zucker', 'g', 'Backzutaten');
INSERT IGNORE INTO guetzli_zutaten (name, einheit, kategorie) VALUES ('Vanillezucker', 'Pck.', 'Backzutaten');
INSERT IGNORE INTO guetzli_zutaten (name, einheit, kategorie) VALUES ('Zitrone', 'Stk.', 'Früchte & Gelee');
INSERT IGNORE INTO guetzli_zutaten (name, einheit, kategorie) VALUES ('Ei', 'Stk.', 'Milchprodukte & Eier');
INSERT IGNORE INTO guetzli_zutaten (name, einheit, kategorie) VALUES ('Mehl', 'g', 'Backzutaten');
INSERT IGNORE INTO guetzli_zutaten (name, einheit, kategorie) VALUES ('Puderzucker', 'g', 'Backzutaten');
INSERT IGNORE INTO guetzli_zutaten (name, einheit, kategorie) VALUES ('Zimt', 'g', 'Gewürze & Aromen');
INSERT IGNORE INTO guetzli_zutaten (name, einheit, kategorie) VALUES ('Kakaopulver', 'g', 'Backzutaten');
INSERT IGNORE INTO guetzli_zutaten (name, einheit, kategorie) VALUES ('gemahlene Mandeln', 'g', 'Nüsse & Kokos');
INSERT IGNORE INTO guetzli_zutaten (name, einheit, kategorie) VALUES ('geschälte, gemahlene Mandeln', 'g', 'Nüsse & Kokos');
INSERT IGNORE INTO guetzli_zutaten (name, einheit, kategorie) VALUES ('Vanillestängel', 'Stk.', 'Gewürze & Aromen');
INSERT IGNORE INTO guetzli_zutaten (name, einheit, kategorie) VALUES ('Gelee', 'g', 'Früchte & Gelee');
INSERT IGNORE INTO guetzli_zutaten (name, einheit, kategorie) VALUES ('Zitronensaft', 'TL', 'Früchte & Gelee');
INSERT IGNORE INTO guetzli_zutaten (name, einheit, kategorie) VALUES ('Kokosraspel', 'g', 'Nüsse & Kokos');
INSERT IGNORE INTO guetzli_zutaten (name, einheit, kategorie) VALUES ('Cornflakes', 'g', 'Sonstiges');
INSERT IGNORE INTO guetzli_zutaten (name, einheit, kategorie) VALUES ('dunkle Schokolade', 'g', 'Schokolade');
INSERT IGNORE INTO guetzli_zutaten (name, einheit, kategorie) VALUES ('Schokoladenpulver', 'g', 'Backzutaten');
INSERT IGNORE INTO guetzli_zutaten (name, einheit, kategorie) VALUES ('Bittermandelaroma', 'Fläschchen', 'Gewürze & Aromen');
INSERT IGNORE INTO guetzli_zutaten (name, einheit, kategorie) VALUES ('Milch', 'ml', 'Milchprodukte & Eier');
INSERT IGNORE INTO guetzli_zutaten (name, einheit, kategorie) VALUES ('Anis', 'EL', 'Gewürze & Aromen');
INSERT IGNORE INTO guetzli_zutaten (name, einheit, kategorie) VALUES ('Stärke', 'EL', 'Backzutaten');
INSERT IGNORE INTO guetzli_zutaten (name, einheit, kategorie) VALUES ('Honig', 'g', 'Sonstiges');
INSERT IGNORE INTO guetzli_zutaten (name, einheit, kategorie) VALUES ('Lebkuchengewürz', 'g', 'Gewürze & Aromen');
INSERT IGNORE INTO guetzli_zutaten (name, einheit, kategorie) VALUES ('gemahlener Rohrzucker', 'g', 'Backzutaten');
INSERT IGNORE INTO guetzli_zutaten (name, einheit, kategorie) VALUES ('Crème fraîche', 'g', 'Milchprodukte & Eier');

-- Sorten (anzahl = Anzahl Kekse laut Excel Zeile 2, NULL wenn leer oder Personenangabe)
INSERT IGNORE INTO guetzli_sorten (name, anzahl, rezept_link, notiz) VALUES ('Mailänderli', 90, 'https://swissmilk.ch/de/rezepte-kochideen/rezepte/LM199906_47_MEN906B046C/mailaenderli/', NULL);
INSERT IGNORE INTO guetzli_sorten (name, anzahl, rezept_link, notiz) VALUES ('Zimetstärn', 70, 'https://swissmilk.ch/de/rezepte-kochideen/rezepte/LM_div_1112_01/zimtsterne/', NULL);
INSERT IGNORE INTO guetzli_sorten (name, anzahl, rezept_link, notiz) VALUES ('Vannile Gipfel', 75, 'https://swissmilk.ch/de/rezepte-kochideen/rezepte/RB_KAF2002_31_B/vanillekipferl/', NULL);
INSERT IGNORE INTO guetzli_sorten (name, anzahl, rezept_link, notiz) VALUES ('Spitzbuebe', 60, 'https://swissmilk.ch/de/rezepte-kochideen/rezepte/RB_KAF2002_27/spitzbuben/', NULL);
INSERT IGNORE INTO guetzli_sorten (name, anzahl, rezept_link, notiz) VALUES ('Kokshüfeli', 40, 'https://gutekueche.ch/kokosnuss-haeufchen-rezept-8304', NULL);
INSERT IGNORE INTO guetzli_sorten (name, anzahl, rezept_link, notiz) VALUES ('Zitrone Engel', NULL, 'https://bettybossi.ch/de/Rezept/ShowRezept/BB_WEGE071101_0030A-40-de', 'Excel-Angabe: 16 Pers (Anzahl Kekse unbekannt)');
INSERT IGNORE INTO guetzli_sorten (name, anzahl, rezept_link, notiz) VALUES ('Schokicornflakes', 40, 'https://swissmilk.ch/de/rezepte-kochideen/rezepte/SM2017_GUEZ_10/cornflakes-guetzli-mit-schokolade-ohne-backen/', NULL);
INSERT IGNORE INTO guetzli_sorten (name, anzahl, rezept_link, notiz) VALUES ('Amaretti', 50, 'https://swissmilk.ch/de/rezepte-kochideen/rezepte/KO2020_SBLV_72/amaretti/', NULL);
INSERT IGNORE INTO guetzli_sorten (name, anzahl, rezept_link, notiz) VALUES ('Schoki sables', NULL, 'https://bettybossi.ch/de/Rezept/ShowRezept/BB_WEGE071101_0022A-40-dea', 'Excel-Angabe: 16 Pers (Anzahl Kekse unbekannt)');
INSERT IGNORE INTO guetzli_sorten (name, anzahl, rezept_link, notiz) VALUES ('SW Butterguetzli', 70, 'https://swissmilk.ch/de/rezepte-kochideen/rezepte/KB_BB_1995_180/schwarzweisse-butterguetzli/', NULL);
INSERT IGNORE INTO guetzli_sorten (name, anzahl, rezept_link, notiz) VALUES ('Brunsli', 60, 'https://swissmilk.ch/de/rezepte-kochideen/rezepte/LM201112_34/brunsli/', NULL);
INSERT IGNORE INTO guetzli_sorten (name, anzahl, rezept_link, notiz) VALUES ('Anisguetzli', NULL, 'https://bettybossi.ch/de/Rezept/ShowRezept/BB_BKXX060801_0374A-40-de', 'Excel-Angabe: 4 Pers (Anzahl Kekse unbekannt)');
INSERT IGNORE INTO guetzli_sorten (name, anzahl, rezept_link, notiz) VALUES ('Meringues', 24, 'https://swissmilk.ch/de/rezepte-kochideen/rezepte/LM200004_14/meringues/', NULL);
INSERT IGNORE INTO guetzli_sorten (name, anzahl, rezept_link, notiz) VALUES ('Engelsaugen', 40, 'https://chefkoch.de/rezepte/160601070188995/Engelsaugen.html', NULL);
INSERT IGNORE INTO guetzli_sorten (name, anzahl, rezept_link, notiz) VALUES ('Lebkuchen', 76, 'https://www.swissmilk.ch/de/rezepte-kochideen/rezepte/RB_GAK2003_18A/lebkuchenmaennchen/?collection=97131&index=3', NULL);
INSERT IGNORE INTO guetzli_sorten (name, anzahl, rezept_link, notiz) VALUES ('Spritzgebäck', NULL, 'https://migusto.migros.ch/de/rezepte/klassisches-butter-spritzgebaeck', NULL);
INSERT IGNORE INTO guetzli_sorten (name, anzahl, rezept_link, notiz) VALUES ('Chocolate Chip Cookies', 76, NULL, 'Rezept-Link fehlt (in der Excel stand der Lebkuchen-Link)');

-- Rezept-Zutaten (Menge pro Rezept)
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Mailänderli'), (SELECT id FROM guetzli_zutaten WHERE name = 'Butter'), 375);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Mailänderli'), (SELECT id FROM guetzli_zutaten WHERE name = 'Zucker'), 375);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Mailänderli'), (SELECT id FROM guetzli_zutaten WHERE name = 'Vanillezucker'), 1.5);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Mailänderli'), (SELECT id FROM guetzli_zutaten WHERE name = 'Zitrone'), 1.5);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Mailänderli'), (SELECT id FROM guetzli_zutaten WHERE name = 'Ei'), 3);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Mailänderli'), (SELECT id FROM guetzli_zutaten WHERE name = 'Mehl'), 750);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Zimetstärn'), (SELECT id FROM guetzli_zutaten WHERE name = 'Vanillezucker'), 2);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Zimetstärn'), (SELECT id FROM guetzli_zutaten WHERE name = 'Ei'), 6);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Zimetstärn'), (SELECT id FROM guetzli_zutaten WHERE name = 'Puderzucker'), 500);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Zimetstärn'), (SELECT id FROM guetzli_zutaten WHERE name = 'Zimt'), 16);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Zimetstärn'), (SELECT id FROM guetzli_zutaten WHERE name = 'Kakaopulver'), 12);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Zimetstärn'), (SELECT id FROM guetzli_zutaten WHERE name = 'gemahlene Mandeln'), 800);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Vannile Gipfel'), (SELECT id FROM guetzli_zutaten WHERE name = 'Butter'), 300);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Vannile Gipfel'), (SELECT id FROM guetzli_zutaten WHERE name = 'Zucker'), 135);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Vannile Gipfel'), (SELECT id FROM guetzli_zutaten WHERE name = 'Vanillezucker'), 1.5);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Vannile Gipfel'), (SELECT id FROM guetzli_zutaten WHERE name = 'Ei'), 3);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Vannile Gipfel'), (SELECT id FROM guetzli_zutaten WHERE name = 'Mehl'), 375);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Vannile Gipfel'), (SELECT id FROM guetzli_zutaten WHERE name = 'Puderzucker'), 25);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Vannile Gipfel'), (SELECT id FROM guetzli_zutaten WHERE name = 'geschälte, gemahlene Mandeln'), 150);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Vannile Gipfel'), (SELECT id FROM guetzli_zutaten WHERE name = 'Vanillestängel'), 1.5);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Spitzbuebe'), (SELECT id FROM guetzli_zutaten WHERE name = 'Butter'), 400);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Spitzbuebe'), (SELECT id FROM guetzli_zutaten WHERE name = 'Vanillezucker'), 2);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Spitzbuebe'), (SELECT id FROM guetzli_zutaten WHERE name = 'Ei'), 2);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Spitzbuebe'), (SELECT id FROM guetzli_zutaten WHERE name = 'Mehl'), 550);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Spitzbuebe'), (SELECT id FROM guetzli_zutaten WHERE name = 'Puderzucker'), 200);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Spitzbuebe'), (SELECT id FROM guetzli_zutaten WHERE name = 'Gelee'), 320);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Kokshüfeli'), (SELECT id FROM guetzli_zutaten WHERE name = 'Ei'), 6);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Kokshüfeli'), (SELECT id FROM guetzli_zutaten WHERE name = 'Puderzucker'), 450);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Kokshüfeli'), (SELECT id FROM guetzli_zutaten WHERE name = 'Zitronensaft'), 3);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Kokshüfeli'), (SELECT id FROM guetzli_zutaten WHERE name = 'Kokosraspel'), 450);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Zitrone Engel'), (SELECT id FROM guetzli_zutaten WHERE name = 'Butter'), 300);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Zitrone Engel'), (SELECT id FROM guetzli_zutaten WHERE name = 'Zucker'), 200);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Zitrone Engel'), (SELECT id FROM guetzli_zutaten WHERE name = 'Zitrone'), 1);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Zitrone Engel'), (SELECT id FROM guetzli_zutaten WHERE name = 'Ei'), 2);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Zitrone Engel'), (SELECT id FROM guetzli_zutaten WHERE name = 'Mehl'), 500);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Zitrone Engel'), (SELECT id FROM guetzli_zutaten WHERE name = 'Puderzucker'), 300);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Zitrone Engel'), (SELECT id FROM guetzli_zutaten WHERE name = 'Zitronensaft'), 10);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Schokicornflakes'), (SELECT id FROM guetzli_zutaten WHERE name = 'Butter'), 50);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Schokicornflakes'), (SELECT id FROM guetzli_zutaten WHERE name = 'Vanillezucker'), 0.5);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Schokicornflakes'), (SELECT id FROM guetzli_zutaten WHERE name = 'Cornflakes'), 160);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Schokicornflakes'), (SELECT id FROM guetzli_zutaten WHERE name = 'dunkle Schokolade'), 400);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Amaretti'), (SELECT id FROM guetzli_zutaten WHERE name = 'Zucker'), 300);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Amaretti'), (SELECT id FROM guetzli_zutaten WHERE name = 'Ei'), 3);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Amaretti'), (SELECT id FROM guetzli_zutaten WHERE name = 'Mehl'), 30);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Amaretti'), (SELECT id FROM guetzli_zutaten WHERE name = 'gemahlene Mandeln'), 400);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Amaretti'), (SELECT id FROM guetzli_zutaten WHERE name = 'Schokoladenpulver'), 15);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Amaretti'), (SELECT id FROM guetzli_zutaten WHERE name = 'Bittermandelaroma'), 1);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Schoki sables'), (SELECT id FROM guetzli_zutaten WHERE name = 'Butter'), 350);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Schoki sables'), (SELECT id FROM guetzli_zutaten WHERE name = 'Zucker'), 150);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Schoki sables'), (SELECT id FROM guetzli_zutaten WHERE name = 'Vanillezucker'), 0.5);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Schoki sables'), (SELECT id FROM guetzli_zutaten WHERE name = 'Mehl'), 500);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Schoki sables'), (SELECT id FROM guetzli_zutaten WHERE name = 'Schokoladenpulver'), 20);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Schoki sables'), (SELECT id FROM guetzli_zutaten WHERE name = 'Milch'), 30);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'SW Butterguetzli'), (SELECT id FROM guetzli_zutaten WHERE name = 'Butter'), 320);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'SW Butterguetzli'), (SELECT id FROM guetzli_zutaten WHERE name = 'Zitrone'), 1);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'SW Butterguetzli'), (SELECT id FROM guetzli_zutaten WHERE name = 'Ei'), 2);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'SW Butterguetzli'), (SELECT id FROM guetzli_zutaten WHERE name = 'Mehl'), 500);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'SW Butterguetzli'), (SELECT id FROM guetzli_zutaten WHERE name = 'Puderzucker'), 100);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'SW Butterguetzli'), (SELECT id FROM guetzli_zutaten WHERE name = 'Kakaopulver'), 30);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Brunsli'), (SELECT id FROM guetzli_zutaten WHERE name = 'Zucker'), 400);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Brunsli'), (SELECT id FROM guetzli_zutaten WHERE name = 'Ei'), 2);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Brunsli'), (SELECT id FROM guetzli_zutaten WHERE name = 'Mehl'), 20);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Brunsli'), (SELECT id FROM guetzli_zutaten WHERE name = 'Zimt'), 5);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Brunsli'), (SELECT id FROM guetzli_zutaten WHERE name = 'Kakaopulver'), 20);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Brunsli'), (SELECT id FROM guetzli_zutaten WHERE name = 'gemahlene Mandeln'), 500);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Brunsli'), (SELECT id FROM guetzli_zutaten WHERE name = 'Schokoladenpulver'), 200);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Anisguetzli'), (SELECT id FROM guetzli_zutaten WHERE name = 'Ei'), 2);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Anisguetzli'), (SELECT id FROM guetzli_zutaten WHERE name = 'Mehl'), 275);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Anisguetzli'), (SELECT id FROM guetzli_zutaten WHERE name = 'Puderzucker'), 225);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Anisguetzli'), (SELECT id FROM guetzli_zutaten WHERE name = 'Anis'), 1);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Meringues'), (SELECT id FROM guetzli_zutaten WHERE name = 'Zucker'), 120);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Meringues'), (SELECT id FROM guetzli_zutaten WHERE name = 'Ei'), 4);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Meringues'), (SELECT id FROM guetzli_zutaten WHERE name = 'Puderzucker'), 100);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Meringues'), (SELECT id FROM guetzli_zutaten WHERE name = 'Stärke'), 1.5);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Engelsaugen'), (SELECT id FROM guetzli_zutaten WHERE name = 'Butter'), 150);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Engelsaugen'), (SELECT id FROM guetzli_zutaten WHERE name = 'Vanillezucker'), 1);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Engelsaugen'), (SELECT id FROM guetzli_zutaten WHERE name = 'Zitrone'), 1);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Engelsaugen'), (SELECT id FROM guetzli_zutaten WHERE name = 'Ei'), 2);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Engelsaugen'), (SELECT id FROM guetzli_zutaten WHERE name = 'Mehl'), 240);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Engelsaugen'), (SELECT id FROM guetzli_zutaten WHERE name = 'Puderzucker'), 70);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Engelsaugen'), (SELECT id FROM guetzli_zutaten WHERE name = 'Gelee'), 50);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Lebkuchen'), (SELECT id FROM guetzli_zutaten WHERE name = 'Butter'), 100);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Lebkuchen'), (SELECT id FROM guetzli_zutaten WHERE name = 'Ei'), 2);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Lebkuchen'), (SELECT id FROM guetzli_zutaten WHERE name = 'Mehl'), 800);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Lebkuchen'), (SELECT id FROM guetzli_zutaten WHERE name = 'Kakaopulver'), 20);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Lebkuchen'), (SELECT id FROM guetzli_zutaten WHERE name = 'Honig'), 250);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Lebkuchen'), (SELECT id FROM guetzli_zutaten WHERE name = 'Lebkuchengewürz'), 20);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Lebkuchen'), (SELECT id FROM guetzli_zutaten WHERE name = 'gemahlener Rohrzucker'), 350);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Lebkuchen'), (SELECT id FROM guetzli_zutaten WHERE name = 'Crème fraîche'), 200);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Spritzgebäck'), (SELECT id FROM guetzli_zutaten WHERE name = 'Butter'), 200);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Spritzgebäck'), (SELECT id FROM guetzli_zutaten WHERE name = 'Zucker'), 150);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Spritzgebäck'), (SELECT id FROM guetzli_zutaten WHERE name = 'Ei'), 2);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Spritzgebäck'), (SELECT id FROM guetzli_zutaten WHERE name = 'Mehl'), 340);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Spritzgebäck'), (SELECT id FROM guetzli_zutaten WHERE name = 'dunkle Schokolade'), 150);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Chocolate Chip Cookies'), (SELECT id FROM guetzli_zutaten WHERE name = 'Butter'), 220);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Chocolate Chip Cookies'), (SELECT id FROM guetzli_zutaten WHERE name = 'Zucker'), 350);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Chocolate Chip Cookies'), (SELECT id FROM guetzli_zutaten WHERE name = 'Vanillezucker'), 0.5);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Chocolate Chip Cookies'), (SELECT id FROM guetzli_zutaten WHERE name = 'Ei'), 2);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Chocolate Chip Cookies'), (SELECT id FROM guetzli_zutaten WHERE name = 'Mehl'), 320);
INSERT IGNORE INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge) VALUES ((SELECT id FROM guetzli_sorten WHERE name = 'Chocolate Chip Cookies'), (SELECT id FROM guetzli_zutaten WHERE name = 'dunkle Schokolade'), 300);
