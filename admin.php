<?php
session_start();
$admin_pass = "WEAR5555.2013DARKHXTE";
$json_file = 'keys.json';

if (isset($_POST['password'])) {
    if ($_POST['password'] === $admin_pass) {
        $_SESSION['admin_logged'] = true;
    } else {
        $error = "Yanlış şifrə!";
    }
}

if (isset($_GET['logout'])) {
    session_destroy();
    header("Location: admin.php");
    exit;
}

if (isset($_SESSION['admin_logged']) && $_SESSION['admin_logged'] === true) {
    if (isset($_POST['generate'])) {
        $keys = file_exists($json_file) ? json_decode(file_get_contents($json_file), true) : [];
        
        $duration_type = $_POST['duration_type']; // 1D, 7D, 30D, LIFETIME
        $note = htmlspecialchars($_POST['note']);
        
        $expire_time = 0;
        $now = time();
        $prefix = "DARKOS-1D-";
        
        if ($duration_type == '1D') {
            $expire_time = $now + (1 * 86400);
            $prefix = "DARKOS-1D-";
        } elseif ($duration_type == '7D') {
            $expire_time = $now + (7 * 86400);
            $prefix = "DARKOS-7D-";
        } elseif ($duration_type == '30D') {
            $expire_time = $now + (30 * 86400);
            $prefix = "DARKOS-30D-";
        } elseif ($duration_type == 'LIFETIME') {
            $expire_time = 0;
            $prefix = "DARKOS-LIFETIME-";
        }

        // Random 17 simvol (hərf və rəqəm)
        $random_str = strtoupper(substr(bin2hex(random_bytes(10)), 0, 17));
        $new_key = $prefix . $random_str;
        
        $keys[$new_key] = [
            'hwid' => '',
            'status' => 'unused',
            'created' => $now,
            'expire' => $expire_time,
            'note' => $note
        ];
        
        file_put_contents($json_file, json_encode($keys, JSON_PRETTY_PRINT));
        header("Location: admin.php");
        exit;
    }
    
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
        body { background: #000000; color: #ffffff; font-family: monospace; padding: 15px; }
        .container { max-width: 650px; margin: 0 auto; background: #000000; border: 1px solid #ffffff; padding: 15px; }
        input, select, button { padding: 10px; margin: 5px 0; width: 100%; border-radius: 0px; border: 1px solid #ffffff; font-size: 15px; box-sizing: border-box; background: #000000; color: #ffffff; font-family: monospace; }
        button { background: #ffffff; color: #000000; cursor: pointer; font-weight: bold; }
        button:hover { background: #cccccc; }
        table { width: 100%; margin-top: 15px; border-collapse: collapse; overflow-x: auto; display: block; }
        th, td { padding: 8px; border: 1px solid #ffffff; text-align: left; font-size: 13px; }
        .del-btn { background: #ffffff; color: #000000; padding: 5px 8px; width: auto; font-size: 12px; border: 1px solid #ffffff; font-weight: bold; }
        .del-btn:hover { background: #999999; }
    </style>
</head>
<body>
<div class="container">
    <h2>DARK IOS - Admin Panel</h2>
    <?php if (!isset($_SESSION['admin_logged']) || $_SESSION['admin_logged'] !== true): ?>
        <form method="POST">
            <?php if (isset($error)) echo "<p style='color:#ffffff;'>$error</p>"; ?>
            <label>Admin Şifrəsi:</label>
            <input type="password" name="password" placeholder="Şifrə" required>
            <button type="submit">Giriş</button>
        </form>
    <?php else: ?>
        <p>Xoş gəldin, Admin! | <a href="admin.php?logout=true" style="color: #ffffff; text-decoration: underline;">Çıxış</a></p>
        
        <form method="POST" style="border: 1px solid #ffffff; padding: 10px; margin-top: 10px;">
            <h4 style="margin: 0 0 5px 0; color: #ffffff;">Yeni Key Yarat</h4>
            <input type="text" name="note" placeholder="Qeyd (məsələn: İstifadəçi adı)">
            
            <select name="duration_type">
                <option value="1D">1 Günlük (1D)</option>
                <option value="7D">7 Günlük (7D - Həftəlik)</option>
                <option value="30D">30 Günlük (30D)</option>
                <option value="LIFETIME">Sınırsız (LIFETIME)</option>
            </select>
            
            <button type="submit" name="generate" style="margin-top: 8px;">Key-i Yarat</button>
        </form>

        <h3>Mövcud Keylər:</h3>
        <table>
            <tr>
                <th>Key / Qeyd</th>
                <th>Müddət / Status</th>
                <th>Əməliyyat</th>
            </tr>
            <?php 
            $keys = file_exists($json_file) ? json_decode(file_get_contents($json_file), true) : [];
            if (!empty($keys)) {
                foreach ($keys as $k => $v) {
                    $note_text = !empty($v['note']) ? "<br><small style='color:#cccccc;'>Qeyd: {$v['note']}</small>" : "";
                    $hwid_text = !empty($v['hwid']) ? "<br><small style='color:#ffffff;'>HWID bağlıdır</small>" : "<br><small style='color:#aaaaaa;'>Boşdur</small>";
                    
                    if ($v['expire'] == 0) {
                        $time_left = "Sınırsız";
                    } else {
                        $left = $v['expire'] - time();
                        if ($left > 0) {
                            $days_left = floor($left / 86400);
                            $hours_left = floor(($left % 86400) / 3600);
                            $time_left = "Qalır: {$days_left}g {$hours_left}s";
                        } else {
                            $time_left = "Vaxtı bitib";
                        }
                    }

                    echo "<tr>
                            <td><b>{$k}</b>{$note_text}</td>
                            <td>{$time_left}{$hwid_text}</td>
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
