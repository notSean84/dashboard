<?php
require_once __DIR__ . '/../../api/config.php';

$db = getDb();
$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {

    case 'GET':
        $stmt = $db->query('SELECT * FROM moto_service_typen ORDER BY bezeichnung ASC');
        jsonResponse($stmt->fetchAll());
        break;

    case 'POST':
        $data = getJsonBody();
        $stmt = $db->prepare(
            'INSERT INTO moto_service_typen (bezeichnung, intervall_km)
             VALUES (:bezeichnung, :intervall_km)'
        );
        $stmt->execute([
            ':bezeichnung'  => $data['bezeichnung'] ?? '',
            ':intervall_km' => $data['intervall_km'] ?? 0,
        ]);
        jsonResponse(['id' => $db->lastInsertId()], 201);
        break;

    case 'PUT':
        $data = getJsonBody();
        $stmt = $db->prepare(
            'UPDATE moto_service_typen
             SET bezeichnung = :bezeichnung, intervall_km = :intervall_km
             WHERE id = :id'
        );
        $stmt->execute([
            ':bezeichnung'  => $data['bezeichnung'] ?? '',
            ':intervall_km' => $data['intervall_km'] ?? 0,
            ':id'           => $data['id'] ?? 0,
        ]);
        jsonResponse(['ok' => true]);
        break;

    case 'DELETE':
        $id = $_GET['id'] ?? 0;
        $stmt = $db->prepare('DELETE FROM moto_service_typen WHERE id = :id');
        $stmt->execute([':id' => $id]);
        jsonResponse(['ok' => true]);
        break;

    default:
        jsonResponse(['error' => 'Methode nicht unterstuetzt'], 405);
}
