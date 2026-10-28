<?php
// Məlumat bazası və ya sadə JSON fayl ilə idarəetmə
$key = $_GET['key'] ?? '';
$device_id = $_GET['hwid'] ?? '';

if (empty($key) || empty($device_id)) {
    echo json_encode(["status" => "error", "message" => "Eksik məlumat"]);
    exit;
}

// Burada öz databazandan key-i yoxlayırsan
// Tutaq ki, key bazadan oxundu:
$stored_key = "Aa11"; 
$bound_device = ""; // Əvvəl bağlanmış cihazın UDID/HWID-i

if ($key !== $stored_key) {
    echo json_encode(["status" => "error", "message" => "Yanlış Key!"]);
    exit;
}

// Əgər key hələ heç bir cihaza bağlanmayıbsa, bu cihazı bağlayırıq
if (empty($bound_device)) {
    $bound_device = $device_id; // İlk girən cihaz bağlanır
    // Bazaya $device_id-ni qeyd et
    echo json_encode(["status" => "success", "message" => "Key uğurla aktivləşdirildi!"]);
} else if ($bound_device === $device_id) {
    // Eyni cihazdırsa girişə icazə ver
    echo json_encode(["status" => "success", "message" => "Xoş gəldiniz!"]);
} else {
    // Başqa cihazdırsa rədd et
    echo json_encode(["status" => "error", "message" => "Bu key başqa cihaza bağlıdır!"]);
}
?>
