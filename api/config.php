<?php
/**
 * Zentrale DB-Verbindung fuer alle Tools.
 * Standard: SQLite (keine Serverinstallation noetig, Datei liegt in /db).
 * Fuer MySQL: DSN unten anpassen und Zugangsdaten setzen.
 */

function getDb(): PDO
{
    static $pdo = null;
    if ($pdo !== null) {
        return $pdo;
    }

    // --- Variante SQLite (Standard) ---
    $dbPath = __DIR__ . '/../db/dashboard.sqlite';
    $pdo = new PDO('sqlite:' . $dbPath);

    // --- Variante MySQL (auskommentiert, bei Bedarf aktivieren) ---
    // $host = 'localhost';
    // $db   = 'dashboard';
    // $user = 'dbuser';
    // $pass = 'dbpass';
    // $pdo = new PDO("mysql:host=$host;dbname=$db;charset=utf8mb4", $user, $pass);

    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
    $pdo->exec('PRAGMA foreign_keys = ON;');

    return $pdo;
}

/** Einheitliche JSON-Antwort inkl. Header */
function jsonResponse($data, int $status = 200): void
{
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
    exit;
}

/** JSON-Body eines Requests einlesen */
function getJsonBody(): array
{
    $raw = file_get_contents('php://input');
    return json_decode($raw, true) ?? [];
}
