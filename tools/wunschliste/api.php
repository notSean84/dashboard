<?php
require_once __DIR__ . '/../../api/config.php';

$db = getDb();
$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {

    case 'GET':
        $stmt = $db->query('SELECT * FROM wunschliste ORDER BY prioritaet ASC, id DESC');
        jsonResponse($stmt->fetchAll());
        break;

    case 'POST':
        $data = getJsonBody();
        $stmt = $db->prepare(
            'INSERT INTO wunschliste (titel, prioritaet, preis, link, notiz)
             VALUES (:titel, :prioritaet, :preis, :link, :notiz)'
        );
        $stmt->execute([
            ':titel'      => $data['titel'] ?? '',
            ':prioritaet' => $data['prioritaet'] ?? 3,
            ':preis'      => $data['preis'] ?? null,
            ':link'       => $data['link'] ?? null,
            ':notiz'      => $data['notiz'] ?? null,
        ]);
        jsonResponse(['id' => $db->lastInsertId()], 201);
        break;

    case 'PUT':
        $data = getJsonBody();
        $stmt = $db->prepare('UPDATE wunschliste SET erledigt = :erledigt WHERE id = :id');
        $stmt->execute([
            ':erledigt' => $data['erledigt'] ?? 0,
            ':id'       => $data['id'] ?? 0,
        ]);
        jsonResponse(['ok' => true]);
        break;

    case 'DELETE':
        $id = $_GET['id'] ?? 0;
        $stmt = $db->prepare('DELETE FROM wunschliste WHERE id = :id');
        $stmt->execute([':id' => $id]);
        jsonResponse(['ok' => true]);
        break;

    default:
        jsonResponse(['error' => 'Methode nicht unterstuetzt'], 405);
}
