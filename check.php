<?php
error_reporting(0);
header('Content-Type: application/json; charset=utf-8');

$json_file = 'keys.json';
$key = isset($_GET['key']) ? trim($_GET['key']) : '';
$hwid = isset($_GET['hwid']) ? trim($_GET['hwid']) : '';

if (empty($key) || empty($hwid)) {
    echo json_encode(["status" => "error", "message" => "Eksik parametre"]);
    exit;
}

$keys = file_exists($json_file) ? json_decode(file_get_contents($json_file), true) : [];
if (!is_array($keys) || !isset($keys[$key])) {
    // Key silinibse və ya yoxdursa oyundan atmaq üçün banned statusu qaytarırıq
    echo json_encode(["status" => "banned", "message" => "Key tapılmadı və ya silinib!"]);
    exit;
}

$keyData = $keys[$key];

// 1. Bloklanıbsa oyundan at
if (isset($keyData['status']) && $keyData['status'] === 'blocked') {
    echo json_encode(["status" => "banned", "message" => "Key bloklanıb!"]);
    exit;
}

// 2. Vaxtı bitibsə oyundan at
if ($keyData['expire'] > 0 && $keyData['expire'] < time()) {
    echo json_encode(["status" => "expired", "message" => "Keyin vaxtı bitib!"]);
    exit;
}

// 3. HWID və Cihaz limiti yoxlaması
$hwidList = isset($keyData['hwid']) ? $keyData['hwid'] : [];
if (!is_array($hwidList)) $hwidList = [];

if (in_array($hwid, $hwidList)) {
    // Cihaz artıq qeydiyyatdadır, icazə ver
    echo json_encode(["status" => "success", "message" => "Giriş uğurludur"]);
    exit;
}

// Yeni cihazdırsa limitə baxırıq
$maxDevices = isset($keyData['max_devices']) ? intval($keyData['max_devices']) : 1;
if (count($hwidList) < $maxDevices) {
    $hwidList[] = $hwid;
    $keys[$key]['hwid'] = $hwidList;
    file_put_contents($json_file, json_encode($keys, JSON_PRETTY_PRINT));
    echo json_encode(["status" => "success", "message" => "Cihaz uğurla bağlandı"]);
    exit;
} else {
    echo json_encode(["status" => "limit_exceeded", "message" => "Cihaz limiti dolub!"]);
    exit;
}
?>
