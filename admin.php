<?php
error_reporting(E_ALL & ~E_WARNING & ~E_NOTICE);
ini_set('display_errors', 0);

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
        if (!is_array($keys)) $keys = [];
        
        $duration_type = $_POST['duration_type'];
        $note = htmlspecialchars($_POST['note']);
        $custom_key = trim($_POST['custom_key']);
        
        $expire_time = 0;
        $now = time();
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

        if (!empty($custom_key)) {
            $new_key = htmlspecialchars($custom_key);
        } else {
            $random_str = strtoupper(substr(bin2hex(random_bytes(10)), 0, 17));
            $new_key = $prefix . $random_str;
        }
        
        $keys[$new_key] = [
            'hwid' => '', 'status' => 'unused',
            'created' => $now, 'expire' => $expire_time, 'note' => $note
        ];
        
        file_put_contents($json_file, json_encode($keys, JSON_PRETTY_PRINT));
        header("Location: admin.php");
        exit;
    }
    
    if (isset($_GET['delete'])) {
        $keys = file_exists($json_file) ? json_decode(file_get_contents($json_file), true) : [];
        if (is_array($keys) && isset($keys[$_GET['delete']])) {
            unset($keys[$_GET['delete']]);
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
    <title>DARK IOS — Admin Panel</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        :root {
            --bg: #0a0a0f;
            --card: #12121a;
            --card-hover: #1a1a24;
            --border: #23232f;
            --text: #ffffff;
            --text-dim: #8b8b9e;
            --accent: #7c3aed;
            --accent-2: #a855f7;
            --success: #10b981;
            --danger: #ef4444;
            --warning: #f59e0b;
        }
        
        body {
            background: var(--bg);
            background-image: 
                radial-gradient(ellipse at top, rgba(124, 58, 237, 0.15), transparent 50%),
                radial-gradient(ellipse at bottom, rgba(168, 85, 247, 0.08), transparent 50%);
            min-height: 100vh;
            color: var(--text);
            font-family: 'Inter', -apple-system, sans-serif;
            padding: 24px 16px;
            line-height: 1.5;
        }
        
        .container { max-width: 900px; margin: 0 auto; }
        
        .header {
            display: flex; align-items: center; justify-content: space-between;
            flex-wrap: wrap; gap: 16px; margin-bottom: 28px;
        }
        
        .brand { display: flex; align-items: center; gap: 12px; }
        
        .logo {
            width: 44px; height: 44px; border-radius: 12px;
            background: linear-gradient(135deg, var(--accent), var(--accent-2));
            display: flex; align-items: center; justify-content: center;
            font-weight: 700; font-size: 18px;
            box-shadow: 0 8px 24px rgba(124, 58, 237, 0.4);
        }
        
        .brand h1 { font-size: 20px; font-weight: 700; letter-spacing: -0.02em; }
        .brand p { font-size: 12px; color: var(--text-dim); }
        
        .logout-btn {
            padding: 10px 18px; border-radius: 10px;
            background: transparent; color: var(--text-dim);
            border: 1px solid var(--border);
            font-family: inherit; font-size: 13px; font-weight: 500;
            cursor: pointer; text-decoration: none;
            transition: all 0.2s;
        }
        .logout-btn:hover { background: var(--card); color: var(--danger); border-color: var(--danger); }
        
        .login-card {
            max-width: 420px; margin: 60px auto;
            background: var(--card); border: 1px solid var(--border);
            border-radius: 20px; padding: 40px 32px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5);
        }
        
        .login-card h2 { font-size: 24px; margin-bottom: 8px; letter-spacing: -0.02em; }
        .login-card .subtitle { color: var(--text-dim); font-size: 14px; margin-bottom: 28px; }
        
        .form-group { margin-bottom: 16px; }
        
        label {
            display: block; font-size: 13px; font-weight: 500;
            color: var(--text-dim); margin-bottom: 8px;
        }
        
        input, select {
            width: 100%; padding: 13px 16px;
            background: var(--bg); color: var(--text);
            border: 1px solid var(--border); border-radius: 10px;
            font-family: inherit; font-size: 14px;
            transition: all 0.2s;
        }
        
        input:focus, select:focus {
            outline: none; border-color: var(--accent);
            box-shadow: 0 0 0 3px rgba(124, 58, 237, 0.15);
        }
        
        input::placeholder { color: #4a4a5a; }
        
        .btn {
            width: 100%; padding: 13px 20px;
            background: linear-gradient(135deg, var(--accent), var(--accent-2));
            color: white; border: none; border-radius: 10px;
            font-family: inherit; font-size: 14px; font-weight: 600;
            cursor: pointer; transition: all 0.2s;
            box-shadow: 0 8px 24px rgba(124, 58, 237, 0.3);
        }
        
        .btn:hover { transform: translateY(-1px); box-shadow: 0 12px 32px rgba(124, 58, 237, 0.45); }
        .btn:active { transform: translateY(0); }
        
        .error {
            background: rgba(239, 68, 68, 0.1); border: 1px solid rgba(239, 68, 68, 0.3);
            color: #fca5a5; padding: 12px 16px; border-radius: 10px;
            font-size: 13px; margin-bottom: 16px;
        }
        
        .stats {
            display: grid; grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
            gap: 12px; margin-bottom: 24px;
        }
        
        .stat {
            background: var(--card); border: 1px solid var(--border);
            border-radius: 14px; padding: 18px;
        }
        
        .stat-label { font-size: 12px; color: var(--text-dim); margin-bottom: 6px; text-transform: uppercase; letter-spacing: 0.05em; }
        .stat-value { font-size: 24px; font-weight: 700; letter-spacing: -0.02em; }
        .stat-value.purple { color: var(--accent-2); }
        .stat-value.green { color: var(--success); }
        .stat-value.orange { color: var(--warning); }
        
        .card {
            background: var(--card); border: 1px solid var(--border);
            border-radius: 16px; padding: 24px; margin-bottom: 24px;
        }
        
        .card h3 { font-size: 16px; font-weight: 600; margin-bottom: 18px; display: flex; align-items: center; gap: 8px; }
        
        .card h3::before {
            content: ''; width: 4px; height: 18px;
            background: linear-gradient(180deg, var(--accent), var(--accent-2));
            border-radius: 2px;
        }
        
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 16px; }
        
        @media (max-width: 600px) { .form-row { grid-template-columns: 1fr; } }
        
        .keys-section h3 { font-size: 16px; font-weight: 600; margin-bottom: 16px; }
        
        .keys-list { display: flex; flex-direction: column; gap: 10px; }
        
        .key-item {
            background: var(--card); border: 1px solid var(--border);
            border-radius: 12px; padding: 16px;
            display: flex; align-items: center; justify-content: space-between;
            gap: 16px; flex-wrap: wrap;
            transition: all 0.2s;
        }
        
        .key-item:hover { border-color: var(--accent); background: var(--card-hover); }
        
        .key-info { flex: 1; min-width: 200px; }
        
        .key-code {
            font-family: 'JetBrains Mono', monospace;
            font-size: 13px; font-weight: 600;
            color: var(--accent-2); margin-bottom: 4px;
            word-break: break-all;
        }
        
        .key-meta {
            display: flex; flex-wrap: wrap; gap: 12px;
            font-size: 12px; color: var(--text-dim);
        }
        
        .badge {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 3px 10px; border-radius: 20px;
            font-size: 11px; font-weight: 600;
        }
        
        .badge.success { background: rgba(16, 185, 129, 0.15); color: var(--success); }
        .badge.warning { background: rgba(245, 158, 11, 0.15); color: var(--warning); }
        .badge.danger  { background: rgba(239, 68, 68, 0.15); color: var(--danger); }
        .badge.info    { background: rgba(124, 58, 237, 0.15); color: var(--accent-2); }
        
        .delete-btn {
            padding: 8px 14px; border-radius: 8px;
            background: transparent; color: var(--danger);
            border: 1px solid rgba(239, 68, 68, 0.3);
            font-family: inherit; font-size: 12px; font-weight: 600;
            cursor: pointer; transition: all 0.2s;
        }
        
        .delete-btn:hover { background: var(--danger); color: white; border-color: var(--danger); }
        
        .empty {
            text-align: center; padding: 40px 20px;
            color: var(--text-dim); font-size: 14px;
            background: var(--card); border: 1px dashed var(--border);
            border-radius: 12px;
        }
    </style>
</head>
<body>
<div class="container">

<?php if (!isset($_SESSION['admin_logged']) || $_SESSION['admin_logged'] !== true): ?>
    
    <div class="login-card">
        <div style="text-align:center; margin-bottom:24px;">
            <div class="logo" style="margin: 0 auto 16px;">D</div>
            <h2>Admin Girişi</h2>
            <p class="subtitle">DARK IOS idarəetmə paneli</p>
        </div>
        <?php if (isset($error)) echo "<div class='error'>⚠️ $error</div>"; ?>
        <form method="POST">
            <div class="form-group">
                <label>Admin Şifrəsi</label>
                <input type="password" name="password" placeholder="••••••••••••" required autofocus>
            </div>
            <button type="submit" class="btn">Daxil ol</button>
        </form>
    </div>

<?php else: ?>
    
    <?php 
    $keys = file_exists($json_file) ? json_decode(file_get_contents($json_file), true) : [];
    if (!is_array($keys)) $keys = [];
    $total = count($keys);
    $unused = 0; $active = 0; $expired = 0;
    foreach ($keys as $v) {
        $status = isset($v['status']) ? $v['status'] : 'unused';
        $expire = isset($v['expire']) ? $v['expire'] : 0;
        
        if ($status === 'unused') $unused++;
        if ($expire > 0 && $expire < time()) $expired++;
        if ($expire == 0 || $expire > time()) $active++;
    }
    ?>
    
    <div class="header">
        <div class="brand">
            <div class="logo">D</div>
            <div>
                <h1>DARK IOS</h1>
                <p>Admin Panel</p>
            </div>
        </div>
        <a href="admin.php?logout=true" class="logout-btn">Çıxış →</a>
    </div>
    
    <div class="stats">
        <div class="stat">
            <div class="stat-label">Cəmi Key</div>
            <div class="stat-value"><?= $total ?></div>
        </div>
        <div class="stat">
            <div class="stat-label">İstifadə olunmayıb</div>
            <div class="stat-value purple"><?= $unused ?></div>
        </div>
        <div class="stat">
            <div class="stat-label">Aktiv</div>
            <div class="stat-value green"><?= $active ?></div>
        </div>
        <div class="stat">
            <div class="stat-label">Vaxtı bitib</div>
            <div class="stat-value orange"><?= $expired ?></div>
        </div>
    </div>
    
    <div class="card">
        <h3>Yeni Key Yarat</h3>
        <form method="POST">
            <div class="form-group">
                <label>Qeyd (istifadəçi adı)</label>
                <input type="text" name="note" placeholder="məsələn: dark_player_01">
            </div>
            
            <div class="form-row">
                <div class="form-group" style="margin-bottom:0;">
                    <label>Müddət</label>
                    <select name="duration_type" id="durationSelect" onchange="updatePlaceholder()">
                        <option value="1D">1 Günlük (1D)</option>
                        <option value="7D">7 Günlük (7D - Həftəlik)</option>
                        <option value="30D">30 Günlük (30D)</option>
                        <option value="LIFETIME">Sınırsız (LIFETIME)</option>
                    </select>
                </div>
                <div class="form-group" style="margin-bottom:0;">
                    <label>Key Kodu (Boş buraxsan avtomatik random gələr)</label>
                    <input type="text" name="custom_key" id="customKeyInput" placeholder="DARKOS-1D-ZA7QQV6U9U4LDAWHST">
                </div>
            </div>
            <button type="submit" name="generate" class="btn" style="margin-top:16px;">+ Key Yarat</button>
        </form>
    </div>

    <script>
    function updatePlaceholder() {
        const select = document.getElementById('durationSelect');
        const input = document.getElementById('customKeyInput');
        const val = select.value;
        const randomPart = "ZA7QQV6U9U4LDAWHST";
        input.placeholder = `DARKOS-${val}-${randomPart}`;
    }
    </script>
    
    <div class="keys-section">
        <h3>Mövcud Keylər (<?= $total ?>)</h3>
        <div class="keys-list">
            <?php if (!empty($keys)): ?>
                <?php foreach ($keys as $k => $v): 
                    $expire = isset($v['expire']) ? $v['expire'] : 0;
                    $note = isset($v['note']) ? $v['note'] : '';
                    $hwid = isset($v['hwid']) ? $v['hwid'] : '';

                    if ($expire == 0) {
                        $time_label = "Sınırsız";
                        $badge_class = 'success';
                    } else {
                        $left = $expire - time();
                        if ($left > 0) {
                            $d = floor($left / 86400);
                            $h = floor(($left % 86400) / 3600);
                            $time_label = "Qalır: {$d}g {$h}s";
                            $badge_class = $d < 1 ? 'warning' : 'success';
                        } else {
                            $time_label = "Vaxtı bitib";
                            $badge_class = 'danger';
                        }
                    }
                ?>
                <div class="key-item">
                    <div class="key-info">
                        <div class="key-code"><?= htmlspecialchars($k) ?></div>
                        <div class="key-meta">
                            <?php if (!empty($note)): ?>
                                <span>📝 <?= htmlspecialchars($note) ?></span>
                            <?php endif; ?>
                            <span class="badge <?= $badge_class ?>"><?= $time_label ?></span>
                            <?php if (!empty($hwid)): ?>
                                <span class="badge info">🔒 HWID bağlı</span>
                            <?php else: ?>
                                <span class="badge info">🔓 Boş</span>
                            <?php endif; ?>
                        </div>
                    </div>
                    <a href="admin.php?delete=<?= urlencode($k) ?>" onclick="return confirm('Bu key silinsin?')">
                        <button class="delete-btn">Sil</button>
                    </a>
                </div>
                <?php endforeach; ?>
            <?php else: ?>
                <div class="empty">📭 Hələ heç bir key yaradılmayıb</div>
            <?php endif; ?>
        </div>
    </div>

<?php endif; ?>

</div>
</body>
</html>
