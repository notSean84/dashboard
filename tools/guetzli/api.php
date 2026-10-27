<?php
require_once __DIR__ . '/../../api/config.php';

/**
 * Guetzli-API (laeuft mit SQLite und MySQL). Ressource per ?resource=sorten|zutaten|einkauf (Standard: sorten)
 *  sorten : GET, POST, PUT, DELETE?id=
 *  zutaten: GET, POST, PUT, DELETE?id=
 *  einkauf: GET (aufsummierter Einkaufszettel aller aktiven Sorten)
 */

$db = getDb();
$method = $_SERVER['REQUEST_METHOD'];
$resource = $_GET['resource'] ?? 'sorten';

function leerZuNull($v)
{
    if ($v === null) return null;
    $v = trim((string)$v);
    return $v === '' ? null : $v;
}

function ladeSorten(PDO $db): array
{
    $sorten = $db->query('SELECT * FROM guetzli_sorten ORDER BY LOWER(name)')->fetchAll();
    $rows = $db->query(
        'SELECT rz.sorte_id, rz.zutat_id, rz.menge, z.name, z.einheit
         FROM guetzli_rezept_zutaten rz
         JOIN guetzli_zutaten z ON z.id = rz.zutat_id
         ORDER BY LOWER(z.name)'
    )->fetchAll();

    $proSorte = [];
    foreach ($rows as $r) {
        $proSorte[(int)$r['sorte_id']][] = [
            'zutat_id' => (int)$r['zutat_id'],
            'name'     => $r['name'],
            'einheit'  => $r['einheit'],
            'menge'    => (float)$r['menge'],
        ];
    }
    foreach ($sorten as &$s) {
        $s['id']     = (int)$s['id'];
        $s['anzahl'] = $s['anzahl'] !== null ? (int)$s['anzahl'] : null;
        $s['faktor'] = (float)$s['faktor'];
        $s['aktiv']  = (int)$s['aktiv'];
        $s['zutaten'] = $proSorte[$s['id']] ?? [];
    }
    return $sorten;
}

function speichereRezeptZutaten(PDO $db, int $sorteId, array $zutaten): void
{
    $db->prepare('DELETE FROM guetzli_rezept_zutaten WHERE sorte_id = :id')->execute([':id' => $sorteId]);
    $ins = $db->prepare(
        'INSERT INTO guetzli_rezept_zutaten (sorte_id, zutat_id, menge)
         VALUES (:sorte, :zutat, :menge)'
    );
    // Gleiche Zutat doppelt erfasst -> Mengen addieren
    $summen = [];
    foreach ($zutaten as $z) {
        $zutatId = (int)($z['zutat_id'] ?? 0);
        $menge   = (float)($z['menge'] ?? 0);
        if ($zutatId <= 0 || $menge <= 0) continue;
        $summen[$zutatId] = ($summen[$zutatId] ?? 0) + $menge;
    }
    foreach ($summen as $zutatId => $menge) {
        $ins->execute([':sorte' => $sorteId, ':zutat' => $zutatId, ':menge' => $menge]);
    }
}

try {
    // ---------------------------------------------------------------- SORTEN
    if ($resource === 'sorten') {
        switch ($method) {

            case 'GET':
                jsonResponse(ladeSorten($db));
                break;

            case 'POST':
                $data = getJsonBody();
                $name = trim($data['name'] ?? '');
                if ($name === '') jsonResponse(['error' => 'Name fehlt'], 400);

                $db->beginTransaction();
                $stmt = $db->prepare(
                    'INSERT INTO guetzli_sorten (name, anzahl, rezept_link, notiz, faktor, aktiv)
                     VALUES (:name, :anzahl, :link, :notiz, :faktor, :aktiv)'
                );
                $stmt->execute([
                    ':name'   => $name,
                    ':anzahl' => leerZuNull($data['anzahl'] ?? null),
                    ':link'   => leerZuNull($data['rezept_link'] ?? null),
                    ':notiz'  => leerZuNull($data['notiz'] ?? null),
                    ':faktor' => max(0.01, (float)($data['faktor'] ?? 1)),
                    ':aktiv'  => (int)($data['aktiv'] ?? 1) ? 1 : 0,
                ]);
                $id = (int)$db->lastInsertId();
                speichereRezeptZutaten($db, $id, $data['zutaten'] ?? []);
                $db->commit();
                jsonResponse(['id' => $id], 201);
                break;

            case 'PUT':
                $data = getJsonBody();
                $id = (int)($data['id'] ?? 0);
                if ($id <= 0) jsonResponse(['error' => 'id fehlt'], 400);

                // Nur uebergebene Felder aktualisieren (z.B. nur aktiv oder faktor)
                $set = [];
                $params = [':id' => $id];
                if (array_key_exists('name', $data)) {
                    $name = trim($data['name']);
                    if ($name === '') jsonResponse(['error' => 'Name fehlt'], 400);
                    $set[] = 'name = :name';  $params[':name'] = $name;
                }
                if (array_key_exists('anzahl', $data))      { $set[] = 'anzahl = :anzahl';      $params[':anzahl'] = leerZuNull($data['anzahl']); }
                if (array_key_exists('rezept_link', $data)) { $set[] = 'rezept_link = :link';   $params[':link']   = leerZuNull($data['rezept_link']); }
                if (array_key_exists('notiz', $data))       { $set[] = 'notiz = :notiz';        $params[':notiz']  = leerZuNull($data['notiz']); }
                if (array_key_exists('faktor', $data))      { $set[] = 'faktor = :faktor';      $params[':faktor'] = max(0.01, (float)$data['faktor']); }
                if (array_key_exists('aktiv', $data))       { $set[] = 'aktiv = :aktiv';        $params[':aktiv']  = (int)$data['aktiv'] ? 1 : 0; }

                $db->beginTransaction();
                if ($set) {
                    $db->prepare('UPDATE guetzli_sorten SET ' . implode(', ', $set) . ' WHERE id = :id')->execute($params);
                }
                if (array_key_exists('zutaten', $data)) {
                    speichereRezeptZutaten($db, $id, $data['zutaten']);
                }
                $db->commit();
                jsonResponse(['ok' => true]);
                break;

            case 'DELETE':
                $stmt = $db->prepare('DELETE FROM guetzli_sorten WHERE id = :id');
                $stmt->execute([':id' => $_GET['id'] ?? 0]);
                jsonResponse(['ok' => true]);
                break;

            default:
                jsonResponse(['error' => 'Methode nicht unterstuetzt'], 405);
        }
    }

    // --------------------------------------------------------------- ZUTATEN
    if ($resource === 'zutaten') {
        switch ($method) {

            case 'GET':
                $stmt = $db->query(
                    'SELECT z.id, z.name, z.einheit, z.kategorie, COUNT(rz.sorte_id) AS verwendet
                     FROM guetzli_zutaten z
                     LEFT JOIN guetzli_rezept_zutaten rz ON rz.zutat_id = z.id
                     GROUP BY z.id
                     ORDER BY LOWER(z.name)'
                );
                $rows = $stmt->fetchAll();
                foreach ($rows as &$r) {
                    $r['id'] = (int)$r['id'];
                    $r['verwendet'] = (int)$r['verwendet'];
                }
                jsonResponse($rows);
                break;

            case 'POST':
                $data = getJsonBody();
                $name = trim($data['name'] ?? '');
                $einheit = trim($data['einheit'] ?? '');
                if ($name === '' || $einheit === '') jsonResponse(['error' => 'Name und Einheit sind Pflicht'], 400);
                $stmt = $db->prepare('INSERT INTO guetzli_zutaten (name, einheit, kategorie) VALUES (:name, :einheit, :kat)');
                $stmt->execute([':name' => $name, ':einheit' => $einheit, ':kat' => leerZuNull($data['kategorie'] ?? null)]);
                jsonResponse(['id' => (int)$db->lastInsertId()], 201);
                break;

            case 'PUT':
                $data = getJsonBody();
                $name = trim($data['name'] ?? '');
                $einheit = trim($data['einheit'] ?? '');
                if ($name === '' || $einheit === '') jsonResponse(['error' => 'Name und Einheit sind Pflicht'], 400);
                $stmt = $db->prepare('UPDATE guetzli_zutaten SET name = :name, einheit = :einheit, kategorie = :kat WHERE id = :id');
                $stmt->execute([
                    ':name' => $name, ':einheit' => $einheit,
                    ':kat' => leerZuNull($data['kategorie'] ?? null),
                    ':id' => (int)($data['id'] ?? 0),
                ]);
                jsonResponse(['ok' => true]);
                break;

            case 'DELETE':
                $stmt = $db->prepare('DELETE FROM guetzli_zutaten WHERE id = :id');
                $stmt->execute([':id' => $_GET['id'] ?? 0]);
                jsonResponse(['ok' => true]);
                break;

            default:
                jsonResponse(['error' => 'Methode nicht unterstuetzt'], 405);
        }
    }

    // ------------------------------------------------------------- EINKAUFEN
    if ($resource === 'einkauf') {
        if ($method !== 'GET') jsonResponse(['error' => 'Methode nicht unterstuetzt'], 405);
        $stmt = $db->query(
            'SELECT z.id, z.name, z.einheit, z.kategorie, SUM(rz.menge * s.faktor) AS menge
             FROM guetzli_rezept_zutaten rz
             JOIN guetzli_sorten s  ON s.id = rz.sorte_id
             JOIN guetzli_zutaten z ON z.id = rz.zutat_id
             WHERE s.aktiv = 1
             GROUP BY z.id
             ORDER BY z.kategorie, LOWER(z.name)'
        );
        $rows = $stmt->fetchAll();
        foreach ($rows as &$r) {
            $r['id'] = (int)$r['id'];
            $r['menge'] = round((float)$r['menge'], 2);
        }
        jsonResponse($rows);
    }

    jsonResponse(['error' => 'Unbekannte Ressource'], 404);

} catch (PDOException $e) {
    if ($db->inTransaction()) $db->rollBack();
    $msg = $e->getMessage();
    if (stripos($msg, 'unique') !== false || stripos($msg, 'duplicate') !== false) {
        jsonResponse(['error' => 'Dieser Name existiert bereits'], 409);
    }
    if (stripos($msg, 'foreign key') !== false) {
        jsonResponse(['error' => 'Zutat wird noch in Rezepten verwendet'], 409);
    }
    jsonResponse(['error' => 'Datenbankfehler'], 500);
}
