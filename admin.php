<?php
session_start();
$admin_pass = "WEAR5555.2013DARKHXTE"; // Sənin admin şifrən
$json_file = 'keys.json';

// Şifrə yoxlaması
if (isset($_POST['password'])) {
    if ($_POST['password'] === $admin_pass) {
        $_SESSION['admin_logged'] = true;
    } else {
        $error = "Yanlış şifrə!";
    }
}

// Çıxış
if (isset($_GET['logout'])) {
    session_destroy();
    header("Location: admin.php");
    exit;
}

// Əgər daxil olubsa və key əlavə etmək istəyirsə
if (isset($_SESSION['admin_logged']) && $_SESSION['admin_logged'] === true) {
    if (isset($_POST['generate'])) {
        $keys = file_exists($json_file) ? json_decode(file_get_contents($json_file), true) : [];
        $new_key = "DARKIOS-" . strtoupper(substr(md5(mt_rand()), 0, 10));
        $keys[$new_key] = [
            'hwid' => '',
            'status' => 'unused',
            'created' => time()
        ];
        file_put_contents($json_file, json_encode($keys, JSON_PRETTY_PRINT));
        header("Location: admin.php");
        exit;
    }
    
    // Key silmək
    if (isset($_GET['delete'])) {
        $key_to_del = $_GET['delete'];
        $keys = file_exists($json_file) ? json_decode(file_get_contents($json_file), true) : [];
        if (isset($keys[$key_to_del])) {
            unset($keys[$key_to_del]);
            file_put_contents($json_file, json_encode($keys, JSON_PRETTY_PRINT));
        }
        header("Location: admin.php");
        exit;
    }
}
?>
<!DOCTYPE html>
<html lang="az">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DARK IOS - Admin Panel</title>
    <style>
        body { background: #0f172a; color: #f8fafc; font-family: sans-serif; padding: 20px; }
        .container { max-width: 600px; margin: 0 auto; background: #1e293b; padding: 20px; border-radius: 10px; box-shadow: 0 4px 10px rgba(0,0,0,0.5); }
        input, button { padding: 10px; margin: 5px 0; width: 100%; border-radius: 5px; border: none; font-size: 16px; }
        input { background: #334155; color: white; }
        button { background: #2563eb; color: white; cursor: pointer; font-weight: bold; }
        button:hover { background: #1d4ed8; }
        table { width: 100%; margin-top: 20px; border-collapse: collapse; }
        th, td { padding: 10px; border-bottom: 1px solid #334155; text-align: left; font-size: 14px; }
        .del-btn { background: #dc2626; padding: 5px 10px; width: auto; }
    </style>
</head>
<body>
<div class="container">
    <h2>DARK IOS - Key Admin Panel</h2>
    <?php if (!isset($_SESSION['admin_logged']) || $_SESSION['admin_logged'] !== true): ?>
        <form method="POST">
            <?php if (isset($error)) echo "<p style='color:red;'>$error</p>"; ?>
            <label>Admin Şifrəsini Daxil Edin:</label>
            <input type="password" name="password" placeholder="Şifrə" required>
            <button type="submit">Giriş</button>
        </form>
    <?php else: ?>
        <p>Xoş gəldin, Admin! | <a href="admin.php?logout=true" style="color: #60a5fa;">Çıxış</a></p>
        <form method="POST">
            <button type="submit" name="generate" style="background: #16a34a;">Yeni Key Yarat</button>
        </form>
        <h3>Mövcud Keylər:</h3>
        <table>
            <tr>
                <th>Key</th>
                <th>HWID</th>
                <th>Əməliyyat</th>
            </tr>
            <?php 
            $keys = file_exists($json_file) ? json_decode(file_get_contents($json_file), true) : [];
            if (!empty($keys)) {
                foreach ($keys as $k => $v) {
                    echo "<tr>
                            <td>{$k}</td>
                            <td>" . (!empty($v['hwid']) ? $v['hwid'] : 'Boş') . "</td>
                            <td><a href='admin.php?delete={$k}'><button class='del-btn'>Sil</button></a></td>
                          </tr>";
                }
            } else {
                echo "<tr><td colspan='3'>Hələ heç bir key yaradılmayıb.</td></tr>";
            }
            ?>
        </table>
    <?php endif; ?>
</div>
</body>
</html>
