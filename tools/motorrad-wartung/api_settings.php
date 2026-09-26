<?php
require_once __DIR__ . '/../../api/config.php';

$db = getDb();
$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {

    case 'GET':
        $schluessel = $_GET['schluessel'] ?? null;
        if ($schluessel) {
            $stmt = $db->prepare('SELECT wert FROM moto_settings WHERE schluessel = :s');
            $stmt->execute([':s' => $schluessel]);
            $row = $stmt->fetch();
            jsonResponse(['wert' => $row['wert'] ?? null]);
        } else {
            $stmt = $db->query('SELECT * FROM moto_settings');
            jsonResponse($stmt->fetchAll());
        }
        break;

    case 'PUT':
    case 'POST':
        $data = getJsonBody();
        // Setzt voraus, dass 'schluessel' PRIMARY KEY ist (MySQL-Syntax).
        $stmt = $db->prepare(
            'INSERT INTO moto_settings (schluessel, wert) VALUES (:s, :w)
             ON DUPLICATE KEY UPDATE wert = VALUES(wert)'
        );
        $stmt->execute([
            ':s' => $data['schluessel'] ?? '',
            ':w' => $data['wert'] ?? '',
        ]);
        jsonResponse(['ok' => true]);
        break;

    default:
        jsonResponse(['error' => 'Methode nicht unterstuetzt'], 405);
}
