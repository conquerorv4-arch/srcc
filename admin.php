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
    $keys = file_exists($json_file) ? json_decode(file_get_contents($json_file), true) : [];
    if (!is_array($keys)) $keys = [];

    // Yeni Key Yaratmaq
    if (isset($_POST['generate'])) {
        $duration_type = $_POST['duration_type'];
        $note = htmlspecialchars($_POST['note']);
        $custom_key = trim($_POST['custom_key']);
        $max_devices = intval($_POST['max_devices']);
        if ($max_devices < 1) $max_devices = 1;
        
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
            'hwid' => [], // Çoxlu cihaz üçün massiv
            'max_devices' => $max_devices,
            'status' => 'active', // active, blocked
            'created' => $now, 
            'expire' => $expire_time, 
            'note' => $note
        ];
        
        file_put_contents($json_file, json_encode($keys, JSON_PRETTY_PRINT));
        header("Location: admin.php");
        exit;
    }
    
    // Key Silmək
    if (isset($_GET['delete'])) {
        $k_del = $_GET['delete'];
        if (isset($keys[$k_del])) {
            unset($keys[$k_del]);
            file_put_contents($json_file, json_encode($keys, JSON_PRETTY_PRINT));
        }
        header("Location: admin.php");
        exit;
    }

    // Bütün Keyləri Silmək
    if (isset($_GET['delete_all'])) {
        file_put_contents($json_file, json_encode([], JSON_PRETTY_PRINT));
        header("Location: admin.php");
        exit;
    }

    // HWID Sıfırlama (Reset)
    if (isset($_GET['reset_hwid'])) {
        $k_target = $_GET['reset_hwid'];
        if (isset($keys[$k_target])) {
            $keys[$k_target]['hwid'] = [];
            file_put_contents($json_file, json_encode($keys, JSON_PRETTY_PRINT));
        }
        header("Location: admin.php");
        exit;
    }

    // Bloklama / Aktivləşdirmə Toggle
    if (isset($_GET['toggle_status'])) {
        $k_target = $_GET['toggle_status'];
        if (isset($keys[$k_target])) {
            $current_status = isset($keys[$k_target]['status']) ? $keys[$k_target]['status'] : 'active';
            $keys[$k_target]['status'] = ($current_status === 'blocked') ? 'active' : 'blocked';
            file_put_contents($json_file, json_encode($keys, JSON_PRETTY_PRINT));
        }
        header("Location: admin.php");
        exit;
    }

    // Vaxt Uzatma
    if (isset($_POST['extend_time'])) {
        $k_target = $_POST['key_name'];
        $add_days = intval($_POST['add_days']);
        if (isset($keys[$k_target])) {
            if ($keys[$k_target]['expire'] == 0) {
                // Lifetime-dırsa toxunmuruq və ya istəsə çeviririk
            } else {
                $current_expire = max($keys[$k_target]['expire'], time());
                $keys[$k_target]['expire'] = $current_expire + ($add_days * 86400);
                file_put_contents($json_file, json_encode($keys, JSON_PRETTY_PRINT));
            }
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
            min-height: 100vh; color: var(--text);
            font-family: 'Inter', -apple-system, sans-serif;
            padding: 24px 16px; line-height: 1.5;
        }
        .container { max-width: 900px; margin: 0 auto; }
        
        .header {
            display: flex; align-items: center; justify-content: space-between;
            flex-wrap: wrap; gap: 16px; margin-bottom: 28px; position: relative;
        }
        .brand { display: flex; align-items: center; gap: 12px; cursor: pointer; }
        .logo {
            width: 44px; height: 44px; border-radius: 12px;
            background: linear-gradient(135deg, var(--accent), var(--accent-2));
            display: flex; align-items: center; justify-content: center;
            font-weight: 700; font-size: 18px; box-shadow: 0 8px 24px rgba(124, 58, 237, 0.4);
            transition: transform 0.2s;
        }
        .logo:hover { transform: scale(1.05); }
        .brand h1 { font-size: 20px; font-weight: 700; letter-spacing: -0.02em; }
        .brand p { font-size: 12px; color: var(--text-dim); }
        
        /* Dropdown Menu */
        .profile-menu {
            position: absolute; top: 60px; left: 0; width: 260px;
            background: var(--card); border: 1px solid var(--border);
            border-radius: 14px; padding: 12px; box-shadow: 0 15px 40px rgba(0,0,0,0.6);
            display: none; z-index: 100; animation: fadeIn 0.2s ease;
        }
        .profile-menu.active { display: block; }
        .menu-item {
            padding: 10px 14px; border-radius: 8px; font-size: 13px; color: var(--text);
            display: flex; align-items: center; gap: 10px; cursor: pointer; text-decoration: none;
            transition: background 0.2s;
        }
        .menu-item:hover { background: var(--card-hover); color: var(--accent-2); }
        .menu-divider { height: 1px; background: var(--border); margin: 6px 0; }

        @keyframes fadeIn { from { opacity: 0; transform: translateY(-8px); } to { opacity: 1; transform: translateY(0); } }

        .logout-btn {
            padding: 10px 18px; border-radius: 10px; background: transparent; color: var(--text-dim);
            border: 1px solid var(--border); font-family: inherit; font-size: 13px; font-weight: 500;
            cursor: pointer; text-decoration: none; transition: all 0.2s;
        }
        .logout-btn:hover { background: var(--card); color: var(--danger); border-color: var(--danger); }
        
        .login-card {
            max-width: 420px; margin: 60px auto; background: var(--card); border: 1px solid var(--border);
            border-radius: 20px; padding: 40px 32px; box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5);
        }
        .login-card h2 { font-size: 24px; margin-bottom: 8px; letter-spacing: -0.02em; }
        .login-card .subtitle { color: var(--text-dim); font-size: 14px; margin-bottom: 28px; }
        
        .form-group { margin-bottom: 16px; }
        label { display: block; font-size: 13px; font-weight: 500; color: var(--text-dim); margin-bottom: 8px; }
        input, select {
            width: 100%; padding: 13px 16px; background: var(--bg); color: var(--text);
            border: 1px solid var(--border); border-radius: 10px; font-family: 'JetBrains Mono', monospace; font-size: 13px;
            transition: all 0.2s;
        }
        input:focus, select:focus { outline: none; border-color: var(--accent); box-shadow: 0 0 0 3px rgba(124, 58, 237, 0.15); }
        input::placeholder { color: #4a4a5a; }
        
        .btn {
            width: 100%; padding: 13px 20px; background: linear-gradient(135deg, var(--accent), var(--accent-2));
            color: white; border: none; border-radius: 10px; font-family: inherit; font-size: 14px; font-weight: 600;
            cursor: pointer; transition: all 0.2s; box-shadow: 0 8px 24px rgba(124, 58, 237, 0.3);
        }
        .btn:hover { transform: translateY(-1px); box-shadow: 0 12px 32px rgba(124, 58, 237, 0.45); }
        .btn.danger { background: linear-gradient(135deg, #ef4444, #dc2626); box-shadow: 0 8px 24px rgba(239, 68, 68, 0.3); }
        
        .error { background: rgba(239, 68, 68, 0.1); border: 1px solid rgba(239, 68, 68, 0.3); color: #fca5a5; padding: 12px 16px; border-radius: 10px; font-size: 13px; margin-bottom: 16px; }
        
        .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(140px, 1fr)); gap: 12px; margin-bottom: 24px; }
        .stat { background: var(--card); border: 1px solid var(--border); border-radius: 14px; padding: 18px; }
        .stat-label { font-size: 12px; color: var(--text-dim); margin-bottom: 6px; text-transform: uppercase; letter-spacing: 0.05em; }
        .stat-value { font-size: 24px; font-weight: 700; letter-spacing: -0.02em; }
        .stat-value.purple { color: var(--accent-2); }
        .stat-value.green { color: var(--success); }
        .stat-value.orange { color: var(--warning); }
        
        .card { background: var(--card); border: 1px solid var(--border); border-radius: 16px; padding: 24px; margin-bottom: 24px; }
        .card h3 { font-size: 16px; font-weight: 600; margin-bottom: 18px; display: flex; align-items: center; gap: 8px; font-family: 'Inter', sans-serif; }
        .card h3::before { content: ''; width: 4px; height: 18px; background: linear-gradient(180deg, var(--accent), var(--accent-2)); border-radius: 2px; }
        
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 16px; }
        @media (max-width: 600px) { .form-row { grid-template-columns: 1fr; } }
        
        /* Axtarış Bölməsi */
        .search-box {
            position: relative; margin-bottom: 16px;
        }
        .search-box input {
            padding-left: 42px; font-family: 'Inter', sans-serif;
        }
        .search-icon {
            position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: var(--text-dim); font-size: 16px;
        }

        .keys-section h3 { font-size: 16px; font-weight: 600; margin-bottom: 16px; font-family: 'Inter', sans-serif; }
        .keys-list { display: flex; flex-direction: column; gap: 10px; }
        
        .key-item {
            background: var(--card); border: 1px solid var(--border); border-radius: 12px; padding: 16px;
            display: flex; align-items: center; justify-content: space-between; gap: 16px; flex-wrap: wrap; transition: all 0.2s;
        }
        .key-item:hover { border-color: var(--accent); background: var(--card-hover); }
        .key-info { flex: 1; min-width: 220px; }
        
        .key-code-row { display: flex; align-items: center; gap: 10px; margin-bottom: 4px; }
        .key-code { font-family: 'JetBrains Mono', monospace; font-size: 13px; font-weight: 600; color: var(--accent-2); word-break: break-all; }
        
        .copy-btn {
            background: rgba(124, 58, 237, 0.15); border: 1px solid rgba(124, 58, 237, 0.3); color: var(--accent-2);
            padding: 4px 8px; border-radius: 6px; font-size: 11px; cursor: pointer; font-weight: 600; transition: all 0.2s;
        }
        .copy-btn:hover { background: var(--accent); color: white; }
        
        .key-meta { display: flex; flex-wrap: wrap; gap: 8px; font-size: 12px; color: var(--text-dim); align-items: center; margin-top: 6px; }
        
        .badge { display: inline-flex; align-items: center; gap: 4px; padding: 3px 10px; border-radius: 20px; font-size: 11px; font-weight: 600; }
        .badge.success { background: rgba(16, 185, 129, 0.15); color: var(--success); }
        .badge.warning { background: rgba(245, 158, 11, 0.15); color: var(--warning); }
        .badge.danger  { background: rgba(239, 68, 68, 0.15); color: var(--danger); }
        .badge.info    { background: rgba(124, 58, 237, 0.15); color: var(--accent-2); }
        
        .action-btns { display: flex; gap: 6px; flex-wrap: wrap; }
        .sm-btn {
            padding: 6px 10px; border-radius: 6px; font-family: inherit; font-size: 11px; font-weight: 600;
            cursor: pointer; transition: all 0.2s; text-decoration: none; border: 1px solid var(--border); background: var(--bg); color: var(--text);
        }
        .sm-btn.reset { border-color: rgba(245, 158, 11, 0.4); color: var(--warning); }
        .sm-btn.reset:hover { background: var(--warning); color: #000; }
        .sm-btn.block { border-color: rgba(239, 68, 68, 0.4); color: var(--danger); }
        .sm-btn.block:hover { background: var(--danger); color: white; }
        .sm-btn.delete { border-color: rgba(239, 68, 68, 0.6); background: rgba(239, 68, 68, 0.1); color: var(--danger); }
        .sm-btn.delete:hover { background: var(--danger); color: white; }
        .sm-btn.extend { border-color: rgba(16, 185, 129, 0.4); color: var(--success); }
        .sm-btn.extend:hover { background: var(--success); color: white; }

        .empty { text-align: center; padding: 40px 20px; color: var(--text-dim); font-size: 14px; background: var(--card); border: 1px dashed var(--border); border-radius: 12px; }
        
        /* Modal Style */
        .modal {
            display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.7); z-index: 1000; align-items: center; justify-content: center; padding: 16px;
        }
        .modal.active { display: flex; }
        .modal-content {
            background: var(--card); border: 1px solid var(--border); border-radius: 16px; width: 100%; max-width: 400px; padding: 24px; box-shadow: 0 20px 50px rgba(0,0,0,0.8);
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
        $status = isset($v['status']) ? $v['status'] : 'active';
        $expire = isset($v['expire']) ? $v['expire'] : 0;
        
        if ($status === 'blocked') {
            // Bloklanıbsa
        } else {
            if ($expire > 0 && $expire < time()) $expired++;
            else $active++;
        }
        if (empty($v['hwid'])) $unused++;
    }
    
    $default_rand = strtoupper(substr(bin2hex(random_bytes(10)), 0, 17));
    $default_key_val = "DARKOS-1D-" . $default_rand;
    ?>
    
    <div class="header">
        <div class="brand" onclick="toggleProfileMenu(event)">
            <div class="logo">D</div>
            <div>
                <h1>DARK IOS</h1>
                <p>Admin Panel</p>
            </div>
        </div>

        <!-- Profil Menyusu (D ikonuna basanda açılır) -->
        <div class="profile-menu" id="profileMenu">
            <div style="font-size:11px; color:var(--text-dim); margin-bottom:8px; text-transform:uppercase; letter-spacing:0.05em;">Sistem Menyu</div>
            <a href="admin.php?delete_all=true" class="menu-item" onclick="return confirm('DİQQƏT: Bütün keylər silinəcək! Əminsinizmi?')">🗑️ Bütün Keyləri Sil</a>
            <div class="menu-divider"></div>
            <a href="admin.php?logout=true" class="menu-item" style="color: var(--danger);">🚪 Hesabdan Çıxış</a>
        </div>

        <a href="admin.php?logout=true" class="logout-btn">Çıxış →</a>
    </div>
    
    <div class="stats">
        <div class="stat">
            <div class="stat-label">Cəmi Key</div>
            <div class="stat-value"><?= $total ?></div>
        </div>
        <div class="stat">
            <div class="stat-label">Boş (İşlənməyib)</div>
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
            <div class="form-row">
                <div class="form-group" style="margin-bottom:0;">
                    <label>Qeyd (İstifadəçi adı)</label>
                    <input type="text" name="note" placeholder="məsələn: dark_player_01" style="font-family: 'Inter', sans-serif;">
                </div>
                <div class="form-group" style="margin-bottom:0;">
                    <label>Maksimum Cihaz Sayı</label>
                    <input type="number" name="max_devices" value="1" min="1" max="10" style="font-family: 'Inter', sans-serif;">
                </div>
            </div>

            <div class="form-row" style="margin-top: 12px;">
                <div class="form-group" style="margin-bottom:0;">
                    <label>Müddət</label>
                    <select name="duration_type" id="durationSelect" onchange="updateKeyFormat()" style="font-family: 'Inter', sans-serif;">
                        <option value="1D">1 Günlük (1D)</option>
                        <option value="7D">7 Günlük (7D - Həftəlik)</option>
                        <option value="30D">30 Günlük (30D)</option>
                        <option value="LIFETIME">Sınırsız (LIFETIME)</option>
                    </select>
                </div>
                <div class="form-group" style="margin-bottom:0;">
                    <label>Key Kodu</label>
                    <input type="text" name="custom_key" id="customKeyInput" value="<?= $default_key_val ?>">
                </div>
            </div>
            <button type="submit" name="generate" class="btn" style="margin-top:16px;">+ Key Yarat</button>
        </form>
    </div>

    <!-- Axtarış Qutusu -->
    <div class="search-box">
        <span class="search-icon">🔍</span>
        <input type="text" id="searchInput" placeholder="Key və ya qeyd üzrə axtar..." onkeyup="searchKeys()">
    </div>
    
    <div class="keys-section">
        <h3>Mövcud Keylər (<span id="keyCount"><?= $total ?></span>)</h3>
        <div class="keys-list" id="keysListContainer">
            <?php if (!empty($keys)): ?>
                <?php foreach ($keys as $k => $v): 
                    $expire = isset($v['expire']) ? $v['expire'] : 0;
                    $note = isset($v['note']) ? $v['note'] : '';
                    $hwid = isset($v['hwid']) ? $v['hwid'] : [];
                    if (!is_array($hwid)) $hwid = !empty($hwid) ? [$hwid] : [];
                    $max_dev = isset($v['max_devices']) ? $v['max_devices'] : 1;
                    $status = isset($v['status']) ? $v['status'] : 'active';

                    if ($status === 'blocked') {
                        $time_label = "Bloklanıb";
                        $badge_class = 'danger';
                    } elseif ($expire == 0) {
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

                    $hwid_count = count($hwid);
                ?>
                <div class="key-item" data-search="<?= strtolower($k . ' ' . $note) ?>">
                    <div class="key-info">
                        <div class="key-code-row">
                            <div class="key-code" id="code_<?= md5($k) ?>"><?= htmlspecialchars($k) ?></div>
                            <button class="copy-btn" onclick="copyKey('code_<?= md5($k) ?>')">Kopyala</button>
                        </div>
                        <div class="key-meta">
                            <?php if (!empty($note)): ?>
                                <span>📝 <?= htmlspecialchars($note) ?></span>
                            <?php endif; ?>
                            <span class="badge <?= $badge_class ?>"><?= $time_label ?></span>
                            <span class="badge info">📱 Cihaz: <?= $hwid_count ?>/<?= $max_dev ?></span>
                            <?php if ($status === 'blocked'): ?>
                                <span class="badge danger">⛔ Bloklu</span>
                            <?php endif; ?>
                        </div>
                    </div>
                    <div class="action-btns">
                        <!-- HWID Reset -->
                        <a href="admin.php?reset_hwid=<?= urlencode($k) ?>" onclick="return confirm('Bu keyin cihaz bağlamaları (HWID) sıfırlansın?')" class="sm-btn reset" title="Cihazları Sıfırla">Reset</a>
                        <!-- Bloklama Toggle -->
                        <a href="admin.php?toggle_status=<?= urlencode($k) ?>" class="sm-btn block"><?= ($status === 'blocked') ? 'Aç' : 'Blokla' ?></a>
                        <!-- Vaxt Artır -->
                        <button onclick="openExtendModal('<?= htmlspecialchars($k) ?>')" class="sm-btn extend">+ Gün</button>
                        <!-- Sil -->
                        <a href="admin.php?delete=<?= urlencode($k) ?>" onclick="return confirm('Bu key silinsin?')" class="sm-btn delete">Sil</a>
                    </div>
                </div>
                <?php endforeach; ?>
            <?php else: ?>
                <div class="empty" id="emptySearch">📭 Hələ heç bir key yaradılmayıb</div>
            <?php endif; ?>
        </div>
    </div>

    <!-- Vaxt Uzatma Modalı -->
    <div class="modal" id="extendModal">
        <div class="modal-content">
            <h3 style="margin-bottom: 14px;">Vaxt Uzat</h3>
            <form method="POST">
                <input type="hidden" name="key_name" id="modalKeyName">
                <div class="form-group">
                    <label>Əlavə olunacaq gün sayı:</label>
                    <input type="number" name="add_days" value="7" min="1" required style="font-family:'Inter', sans-serif;">
                </div>
                <div style="display: flex; gap: 10px;">
                    <button type="submit" name="extend_time" class="btn">Təsdiq Et</button>
                    <button type="button" class="btn" style="background:var(--border); color:var(--text);" onclick="closeExtendModal()">Ləğv Et</button>
                </div>
            </form>
        </div>
    </div>

    <script>
    // Profil menyu aç/bağla
    function toggleProfileMenu(event) {
        event.stopPropagation();
        const menu = document.getElementById('profileMenu');
        menu.classList.toggle('active');
    }
    window.onclick = function() {
        document.getElementById('profileMenu').classList.remove('active');
    }

    // Kopyalama funksiyası
    function copyKey(elementId) {
        const text = document.getElementById(elementId).innerText;
        navigator.clipboard.writeText(text).then(() => {
            alert('Key kopyalandı: ' + text);
        });
    }

    // Axtarış funksiyası
    function searchKeys() {
        let input = document.getElementById('searchInput').value.toLowerCase();
        let items = document.getElementsByClassName('key-item');
        let count = 0;
        
        for (let i = 0; i < items.length; i++) {
            let data = items[i].getAttribute('data-search');
            if (data.includes(input)) {
                items[i].style.display = 'flex';
                count++;
            } else {
                items[i].style.display = 'none';
            }
        }
        document.getElementById('keyCount').innerText = count;
    }

    // Modal idarəsi
    function openExtendModal(keyName) {
        document.getElementById('modalKeyName').value = keyName;
        document.getElementById('extendModal').classList.add('active');
    }
    function closeExtendModal() {
        document.getElementById('extendModal').classList.remove('active');
    }

    // Random key format
    function generateRandomString() {
        const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        let result = '';
        for (let i = 0; i < 17; i++) {
            result += chars.charAt(Math.floor(Math.random() * chars.length));
        }
        return result;
    }

    function updateKeyFormat() {
        const select = document.getElementById('durationSelect');
        const input = document.getElementById('customKeyInput');
        const val = select.value;
        const randomPart = generateRandomString();
        input.value = `DARKOS-${val}-${randomPart}`;
    }
    </script>

<?php endif; ?>

</div>
</body>
</html>
