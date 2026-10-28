<?php
$jsonFile = 'keys.json';

// Şifrə qoruması (özünə uyğun dəyişə bilərsən, məsələn: admin123)
$adminPassword = "admin123"; 
$isLoggedIn = false;

if (isset($_POST['password'])) {
    if ($_POST['password'] === $adminPassword) {
        setcookie("admin_logged", $adminPassword, time() + 3600);
        $isLoggedIn = true;
    }
}

if (isset($_COOKIE['admin_logged']) && $_COOKIE['admin_logged'] === $adminPassword) {
    $isLoggedIn = true;
}

// Yeni key yaratmaq və ya təmizləmək (Reset)
if ($isLoggedIn && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $keysData = file_exists($jsonFile) ? json_decode(file_get_contents($jsonFile), true) : [];
    
    if (isset($_POST['action'])) {
        if ($_POST['action'] === 'add' && !empty($_POST['new_key'])) {
            $newKey = trim($_POST['new_key']);
            $keysData[$newKey] = ""; // Yeni key boş olaraq əlavə olunur
            file_put_contents($jsonFile, json_encode($keysData, JSON_PRETTY_PRINT));
        } 
        elseif ($_POST['action'] === 'reset' && isset($_POST['key_name'])) {
            $keyName = $_POST['key_name'];
            if (isset($keysData[$keyName])) {
                $keysData[$keyName] = ""; // Cihaz bağlamasını sıfırlayır (başqa telefon qşula bilsin deyə)
                file_put_contents($jsonFile, json_encode($keysData, JSON_PRETTY_PRINT));
            }
        }
        elseif ($_POST['action'] === 'delete' && isset($_POST['key_name'])) {
            $keyName = $_POST['key_name'];
            unset($keysData[$keyName]); // Key-i tamamilə silir
            file_put_contents($jsonFile, json_encode($keysData, JSON_PRETTY_PRINT));
        }
    }
    header("Location: admin.php");
    exit;
}
?>

<!DOCTYPE html>
<html lang="az">
<head>
    <meta charset="UTF-8">
    <title>DARK IOS - Admin Panel</title>
    <style>
        body { background: #000; color: #fff; font-family: Arial, sans-serif; padding: 20px; }
        .container { max-width: 600px; margin: 0 auto; background: #111; padding: 20px; border-radius: 8px; border: 1px solid #333; }
        input, button { padding: 10px; margin: 5px 0; background: #222; color: #fff; border: 1px solid #444; border-radius: 4px; }
        button { cursor: pointer; background: #fff; color: #000; font-weight: bold; }
        button:hover { background: #ccc; }
        table { width: 100%; margin-top: 20px; border-collapse: collapse; }
        th, td { padding: 10px; border: 1px solid #333; text-align: left; font-size: 14px; }
        th { background: #1a1a1a; }
        .red { color: #ff4444; }
        .green { color: #44ff44; }
    </style>
</head>
<body>
<div class="container">
    <h2>DARK IOS - Key Admin Panel</h2>
    
    <?php if (!$isLoggedIn): ?>
        <form method="POST">
            <p>Admin Şifrəsini Daxil Edin:</p>
            <input type="password" name="password" placeholder="Şifrə" required>
            <button type="submit">Giriş</button>
        </form>
    <?php else: ?>
        <hr style="border-color: #333;">
        <h3>Yeni Key Əlavə Et</h3>
        <form method="POST">
            <input type="hidden" name="action" value="add">
            <input type="text" name="new_key" placeholder="Məsələn: Aa11" required>
            <button type="submit">Key Yarat</button>
        </form>

        <h3 style="margin-top: 30px;">Mövcud Keylər</h3>
        <table>
            <tr>
                <th>Key (Açar)</th>
                <th>Cihaz Vəziyyəti (HWID)</th>
                <th>Əməliyyatlar</th>
            </tr>
            <?php
            $keysData = file_exists($jsonFile) ? json_decode(file_get_contents($jsonFile), true) : [];
            if (!empty($keysData)) {
                foreach ($keysData as $k => $device) {
                    echo "<tr>";
                    echo "<td><strong>{$k}</strong></td>";
                    if (empty($device)) {
                        echo "<td class='green'>Boşdur (Hələ heç kəsə bağlanmayıb)</td>";
                    } else {
                        echo "<td class='red'>Bağlanıb: <small>{$device}</small></td>";
                    }
                    echo "<td>";
                    // Bağlantını sıfırlamaq düyməsi (başqa cihaz girə bilsin deyə)
                    if (!empty($device)) {
                        echo "<form method='POST' style='display:inline;'>
                                <input type='hidden' name='action' value='reset'>
                                <input type='hidden' name='key_name' value='{$k}'>
                                <button type='submit' style='background:#ffa500; color:#000; padding:5px 8px; font-size:12px;'>Sıfırla</button>
                              </form> ";
                    }
                    // Silmək düyməsi
                    echo "<form method='POST' style='display:inline;'>
                            <input type='hidden' name='action' value='delete'>
                            <input type='hidden' name='key_name' value='{$k}'>
                            <button type='submit' style='background:#ff4444; color:#fff; padding:5px 8px; font-size:12px;'>Sil</button>
                          </form>";
                    echo "</td>";
                    echo "end";
                }
            } else {
                echo "<tr><td colspan='3' style='text-align:center;'>Hələ heç bir key yoxdur.</td></tr>";
            }
            ?>
        </table>
    <?php endif; ?>
</div>
</body>
</html>
