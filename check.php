<?php
$keys_file = 'keys.json';
$key = isset($_GET['key']) ? trim($_GET['key']) : '';
$hwid = isset($_GET['hwid']) ? trim($_GET['hwid']) : '';

if (empty($key) || empty($hwid)) {
    echo json_encode(["status" => "error", "message" => "Eksik"]);
    exit;
}

$keys = file_exists($keys_file) ? json_decode(file_get_contents($keys_file), true) : [];

if (!isset($keys[$key])) {
    echo json_encode(["status" => "error", "message" => "Yanlis"]);
    exit;
}

$data = $keys[$key];
if (!is_array($data)) {
    $data = ['expires' => (int)$data, 'hwid' => [], 'max_devices' => 1];
}

if (time() > $data['expires']) {
    echo json_encode(["status" => "error", "message" => "Vaxti bitib"]);
    exit;
}

if (in_array($hwid, $data['hwid'])) {
    echo json_encode(["status" => "success", "message" => "OK"]);
    exit;
}

if (count($data['hwid']) < $data['max_devices']) {
    $data['hwid'][] = $hwid;
    $keys[$key] = $data;
    file_put_contents($keys_file, json_encode($keys, JSON_PRETTY_PRINT));
    echo json_encode(["status" => "success", "message" => "OK"]);
    exit;
} else {
    echo json_encode(["status" => "error", "message" => "Limit dolub"]);
    exit;
}
?>
