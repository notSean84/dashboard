<?php
require_once __DIR__ . '/../../api/config.php';

$db = getDb();
$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {

    case 'GET':
        $stmt = $db->query('SELECT * FROM moto_log ORDER BY kilometerstand DESC, id DESC');
        jsonResponse($stmt->fetchAll());
        break;

    case 'POST':
        $data = getJsonBody();
        $stmt = $db->prepare(
            'INSERT INTO moto_log (datum, kilometerstand, art, kosten, notiz)
             VALUES (:datum, :kilometerstand, :art, :kosten, :notiz)'
        );
        $stmt->execute([
            ':datum'          => $data['datum'] ?? date('Y-m-d'),
            ':kilometerstand' => $data['kilometerstand'] ?? 0,
            ':art'            => $data['art'] ?? '',
            ':kosten'         => $data['kosten'] ?? null,
            ':notiz'          => $data['notiz'] ?? null,
        ]);
        jsonResponse(['id' => $db->lastInsertId()], 201);
        break;

    case 'PUT':
        $data = getJsonBody();
        $stmt = $db->prepare(
            'UPDATE moto_log
             SET datum = :datum, kilometerstand = :kilometerstand, art = :art,
                 kosten = :kosten, notiz = :notiz
             WHERE id = :id'
        );
        $stmt->execute([
            ':datum'          => $data['datum'] ?? date('Y-m-d'),
            ':kilometerstand' => $data['kilometerstand'] ?? 0,
            ':art'            => $data['art'] ?? '',
            ':kosten'         => $data['kosten'] ?? null,
            ':notiz'          => $data['notiz'] ?? null,
            ':id'             => $data['id'] ?? 0,
        ]);
        jsonResponse(['ok' => true]);
        break;

    case 'DELETE':
        $id = $_GET['id'] ?? 0;
        $stmt = $db->prepare('DELETE FROM moto_log WHERE id = :id');
        $stmt->execute([':id' => $id]);
        jsonResponse(['ok' => true]);
        break;

    default:
        jsonResponse(['error' => 'Methode nicht unterstuetzt'], 405);
}
