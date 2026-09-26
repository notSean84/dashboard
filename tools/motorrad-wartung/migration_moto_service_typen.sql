-- Neue Tabelle fuer Service-Typen inkl. Intervall (Motorrad-Wartung).
-- In phpMyAdmin bei der Datenbank shug_dashboard im Tab "SQL" ausfuehren.
-- moto_log und moto_settings existieren laut Screenshot bereits und bleiben unveraendert.

CREATE TABLE IF NOT EXISTS moto_service_typen (
    id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    bezeichnung VARCHAR(100) NOT NULL,
    intervall_km INT(11) NOT NULL,
    erstellt_am DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
