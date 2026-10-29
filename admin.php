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
        
        $duration_type = $_POST['duration_type']; // hours, days, months, lifetime
        $duration_val = intval($_POST['duration_val']);
        $note = htmlspecialchars($_POST['note']);
        
        $expire_time = 0;
        $now = time();
        
        if ($duration_type == 'hours') {
            $expire_time = $now + ($duration_val * 3600);
        } elseif ($duration_type == 'days') {
            $expire_time = $now + ($duration_val * 86400);
        } elseif ($duration_type == 'months') {
            $expire_time = $now + ($duration_val * 2592000);
        } elseif ($duration_type == 'lifetime') {
            $expire_time = 0; // Sınırsız
        }

        $custom_name = trim($_POST['custom_name']);
        $new_key = !empty($custom_name) ? $custom_name : "DARKIOS-" . strtoupper(substr(md5(mt_rand()), 0, 10));
        
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
    <title>DARK IOS - Key Admin Panel</title>
    <style>
        body { background: #0f172a; color: #f8fafc; font-family: sans-serif; padding: 15px; }
        .container { max-width: 650px; margin: 0 auto; background: #1e293b; padding: 15px; border-radius: 10px; box-shadow: 0 4px 10px rgba(0,0,0,0.5); }
        input, select, button { padding: 10px; margin: 5px 0; width: 100%; border-radius: 5px; border: none; font-size: 15px; box-sizing: border-box; }
        input, select { background: #334155; color: white; }
        button { background: #2563eb; color: white; cursor: pointer; font-weight: bold; }
        button:hover { background: #1d4ed8; }
        table { width: 100%; margin-top: 15px; border-collapse: collapse; overflow-x: auto; display: block; }
        th, td { padding: 8px; border-bottom: 1px solid #334155; text-align: left; font-size: 13px; }
        .del-btn { background: #dc2626; padding: 5px 8px; width: auto; font-size: 12px; }
        .row { display: flex; gap: 5px; }
    </style>
</head>
<body>
<div class="container">
    <h2>DARK IOS - Admin Panel</h2>
    <?php if (!isset($_SESSION['admin_logged']) || $_SESSION['admin_logged'] !== true): ?>
        <form method="POST">
            <?php if (isset($error)) echo "<p style='color:red;'>$error</p>"; ?>
            <label>Admin Şifrəsi:</label>
            <input type="password" name="password" placeholder="Şifrə" required>
            <button type="submit">Giriş</button>
        </form>
    <?php else: ?>
        <p>Xoş gəldin, Admin! | <a href="admin.php?logout=true" style="color: #60a5fa;">Çıxış</a></p>
        
        <form method="POST" style="background: #0f172a; padding: 10px; border-radius: 8px; margin-top: 10px;">
            <h4 style="margin: 0 0 5px 0; color: #38bdf8;">Yeni Key Yarat</h4>
            <input type="text" name="custom_name" placeholder="Xüsusi Key Adı (Boş buraxğanda avtomatik yaranır)">
            <input type="text" name="note" placeholder="Qeyd (məsələn: İstifadəçi adı və ya müştəri)">
            
            <div class="row">
                <input type="number" name="duration_val" value="1" placeholder="Müddət sayı" required>
                <select name="duration_type">
                    <option value="hours">Saat</option>
                    <option value="days" selected>Gün</option>
                    <option value="months">Ay</option>
                    <option value="lifetime">Sınırsız (Lifetime)</option>
                </select>
            </div>
            
            <button type="submit" name="generate" style="background: #16a34a; margin-top: 8px;">Key-i Yarat</button>
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
                    $note_text = !empty($v['note']) ? "<br><small style='color:#38bdf8;'>Qeyd: {$v['note']}</small>" : "";
                    $hwid_text = !empty($v['hwid']) ? "<br><small style='color:#facc15;'>HWID bağlıdır</small>" : "<br><small style='color:#4ade80;'>Boşdur</small>";
                    
                    if ($v['expire'] == 0) {
                        $time_left = "Sınırsız";
                    } else {
                        $left = $v['expire'] - time();
                        if ($left > 0) {
                            $days_left = floor($left / 86400);
                            $hours_left = floor(($left % 86400) / 3600);
                            $time_left = "Qalır: {$days_left}g {$hours_left}s";
                        } else {
                            $time_left = "<span style='color:red;'>Vaxtı bitib</span>";
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
