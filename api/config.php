<?php
/**
 * Zentrale DB-Verbindung fuer alle Tools (MySQL / MariaDB).
 * Nur die vier Werte unten anpassen.
 */

const DB_HOST = 'localhost:3306';
const DB_NAME = 'shug';
const DB_USER = 'shug';
const DB_PASS = '*PN7Rmm8e!ocme5n';

function getDb(): PDO
{
    static $pdo = null;
    if ($pdo !== null) {
        return $pdo;
    }

    try {
        $pdo = new PDO(
            'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=utf8mb4',
            DB_USER,
            DB_PASS,
            [
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES   => false,
            ]
        );
    } catch (PDOException $e) {
        // Zugangsdaten nicht nach aussen geben
        jsonResponse(['error' => 'Datenbankverbindung fehlgeschlagen'], 500);
    }

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