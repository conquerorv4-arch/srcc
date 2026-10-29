<?php
session_start();
$admin_pass = "WEAR5555.2013DARKHXTE";
$json_file = "keys.json";

if (!file_exists($json_file)) {
    file_put_contents($json_file, json_encode([]));
}

$keys_data = json_decode(file_get_contents($json_file), true);

if (isset($_GET['action']) && $_GET['action'] == 'logout') {
    unset($_SESSION['logged_in']);
    header("Location: admin.php");
    exit;
}

if (isset($_POST['login'])) {
    if ($_POST['password'] === $admin_pass) {
        $_SESSION['logged_in'] = true;
        header("Location: admin.php");
        exit;
    } else {
        $login_error = "Şifrə səhvdir!";
    }
}

if (!isset($_SESSION['logged_in']) || $_SESSION['logged_in'] !== true) {
    ?>
    <!DOCTYPE html>
    <html lang="az">
    <head>
        <meta charset="UTF-8">
        <title>Admin Login - DARK IOS</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            body { background: #000; color: #fff; font-family: monospace; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
            .login-box { background: #111; padding: 30px; border: 1px solid #333; border-radius: 8px; width: 300px; text-align: center; }
            input { width: 100%; padding: 10px; margin: 10px 0; background: #222; border: 1px solid #444; color: #fff; border-radius: 4px; box-sizing: border-box; }
            button { width: 100%; padding: 10px; background: #fff; color: #000; border: none; font-weight: bold; border-radius: 4px; cursor: pointer; }
            button:hover { background: #ccc; }
            .error { color: #ff4444; font-size: 14px; }
        </style>
    </head>
    <body>
        <div class="login-box">
            <h2>DARK ADMIN</h2>
            <?php if(isset($login_error)) echo "<p class='error'>$login_error</p>"; ?>
            <form method="POST">
                <input type="password" name="password" placeholder="Admin Şifrəsi" required>
                <button type="submit" name="login">GİRİŞ</button>
            </form>
        </div>
    </body>
    </html>
    <?php
    exit;
}

// Əməliyyatlar (Key yaratma, silmə, bloklama, reset və s.)
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['create_key'])) {
        $duration_type = $_POST['duration_type'];
        $note = htmlspecialchars($_POST['note']);
        $custom_key = trim($_POST['custom_key']);
        $max_devices = intval($_POST['max_devices']);
        if ($max_devices < 1) $max_devices = 1;
        
        $now = time();
        $expire_time = $now + 86400;
        $prefix = "DARKOS-1D-";
        
        if ($duration_type == '1D') { 
            $expire_time = $now + 86400; 
            $prefix = "DARKOS-1D-"; 
        }
        elseif ($duration_type == '7D') { 
            $expire_time = $now + (7 * 86400); 
            $prefix = "DARKOS-7D-"; 
        }
        elseif ($duration_type == '30D') { 
            $expire_time = $now + (30 * 86400); 
            $prefix = "DARKOS-30D-"; 
        }
        elseif ($duration_type == 'LIFETIME') { 
            $expire_time = 0; 
            $prefix = "DARKOS-LIFETIME-"; 
        }

        $random_part = strtoupper(bin2hex(random_bytes(4)));
        $key = !empty($custom_key) ? $custom_key : $prefix . $random_part;

        $keys_data[$key] = [
            "note" => $note,
            "expire" => $expire_time,
            "max_devices" => $max_devices,
            "devices" => [],
            "status" => "active"
        ];

        file_put_contents($json_file, json_encode($keys_data, JSON_PRETTY_PRINT));
        header("Location: admin.php");
        exit;
    }

    if (isset($_POST['action_key'])) {
        $k = $_POST['key_id'];
        $act = $_POST['sub_action'];
        
        if (isset($keys_data[$k])) {
            if ($act == 'delete') {
                unset($keys_data[$k]);
            } elseif ($act == 'block') {
                $keys_data[$k]['status'] = ($keys_data[$k]['status'] == 'banned') ? 'active' : 'banned';
            } elseif ($act == 'reset_hwid') {
                $keys_data[$k]['devices'] = [];
            } elseif ($act == 'add_time') {
                if ($keys_data[$k]['expire'] > 0) {
                    $keys_data[$k]['expire'] += 86400; // 1 gün əlavə et
                }
            } elseif ($act == 'limit_inc') {
                $keys_data[$k]['max_devices']++;
            }
            file_put_contents($json_file, json_encode($keys_data, JSON_PRETTY_PRINT));
        }
        header("Location: admin.php");
        exit;
    }

    if (isset($_POST['delete_all'])) {
        $keys_data = [];
        file_put_contents($json_file, json_encode($keys_data, JSON_PRETTY_PRINT));
        header("Location: admin.php");
        exit;
    }
}
?>
<!DOCTYPE html>
<html lang="az">
<head>
    <meta charset="UTF-8">
    <title>Admin Panel - DARK IOS</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body { background: #0b0c10; color: #c5c6c7; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; margin: 0; padding: 20px; }
        .container { max-width: 800px; margin: auto; }
        h2, h3 { color: #fff; }
        .card { background: #1f2833; padding: 20px; border-radius: 8px; margin-bottom: 20px; border: 1px solid #28313d; }
        input, select { width: 100%; padding: 12px; margin: 8px 0; background: #0b0c10; border: 1px solid #45a29e; color: #fff; border-radius: 6px; box-sizing: border-box; }
        button { padding: 12px 20px; background: #66fcf1; color: #0b0c10; border: none; font-weight: bold; border-radius: 6px; cursor: pointer; width: 100%; }
        button:hover { background: #45a29e; }
        .key-item { background: #0b0c10; padding: 15px; border-radius: 6px; margin-bottom: 10px; border: 1px solid #28313d; }
        .actions form { display: inline-block; margin-right: 5px; margin-top: 5px; }
        .actions button { padding: 6px 12px; font-size: 12px; width: auto; }
        .btn-danger { background: #ff4444; color: #fff; }
        .btn-warning { background: #ffbb33; color: #000; }
        .btn-success { background: #00C851; color: #fff; }
        .flex { display: flex; gap: 10px; }
    </style>
</head>
<body>
<div class="container">
    <div style="display: flex; justify-content: space-between; align-items: center;">
        <h2>DARK IOS Admin Panel</h2>
        <a href="admin.php?action=logout" style="color: #ff4444; text-decoration: none;">Çıxış</a>
    </div>

    <div class="card">
        <h3>Yeni Key Yarat</h3>
        <form method="POST">
            <input type="text" name="note" placeholder="Qeyd (İstifadəçi adı və ya məlumat)">
            <div class="flex">
                <input type="number" name="max_devices" value="1" min="1" placeholder="Maks Cihaz">
                <select name="duration_type">
                    <option value="1D">1 Günlük (1D)</option>
                    <option value="7D">7 Günlük (7D)</option>
                    <option value="30D">30 Günlük (30D)</option>
                    <option value="LIFETIME">Sınırsız (LIFETIME)</option>
                </select>
            </div>
            <input type="text" name="custom_key" placeholder="Özəl Key (Boş buraxarsanız avtomatik yaranacaq)">
            <button type="submit" name="create_key">+ Key Yarat</button>
        </form>
    </div>

    <div class="card">
        <h3>Mövcud Keylər (<?= count($keys_data) ?>)</h3>
        <?php if(count($keys_data) > 0): ?>
            <form method="POST" onsubmit="return confirm('Bütün keyləri silmək istədiyinizə əminsiniz?');">
                <button type="submit" name="delete_all" class="btn-danger" style="margin-bottom: 15px;">Bütün Keyləri Sil</button>
            </form>
        <?php endif; ?>
        
        <?php foreach($keys_data as $k => $v): ?>
            <div class="key-item">
                <strong><?= htmlspecialchars($k) ?></strong> 
                <?php if(!empty($v['note'])): ?> <span style="color:#66fcf1;">(<?= htmlspecialchars($v['note']) ?>)</span> <?php endif; ?><br>
                <small>
                    Status: <b><?= $v['status'] ?></b> | 
                    Müddət: <?= ($v['expire'] == 0) ? "Sınırsız" : ceil(($v['expire'] - time())/86400) . " gün qaldı" ?> | 
                    Cihaz: <?= count($v['devices']) ?>/<?= $v['max_devices'] ?>
                </small>
                <div class="actions">
                    <form method="POST"><input type="hidden" name="key_id" value="<?= $k ?>"><input type="hidden" name="sub_action" value="reset_hwid"><button type="submit" name="action_key" class="btn-warning">HWID Sıfırla</button></form>
                    <form method="POST"><input type="hidden" name="key_id" value="<?= $k ?>"><input type="hidden" name="sub_action" value="block"><button type="submit" name="action_key" class="btn-danger"><?= ($v['status']=='banned')?'Aç':'Blokla' ?></button></form>
                    <form method="POST"><input type="hidden" name="key_id" value="<?= $k ?>"><input type="hidden" name="sub_action" value="add_time"><button type="submit" name="action_key" class="btn-success">+1 Gün</button></form>
                    <form method="POST"><input type="hidden" name="key_id" value="<?= $k ?>"><input type="hidden" name="sub_action" value="limit_inc"><button type="submit" name="action_key" class="btn-warning">+Cihaz</button></form>
                    <form method="POST"><input type="hidden" name="key_id" value="<?= $k ?>"><input type="hidden" name="sub_action" value="delete"><button type="submit" name="action_key" class="btn-danger">Sil</button></form>
                </div>
            </div>
        <?php endforeach; ?>
    </div>
</div>
</body>
</html>
