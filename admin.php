<?php
session_start();
$admin_pass = "WEAR5555.2013DARKHXTE";
$json_file = "keys.json";

// Fayl yoxdursa yarat, amma varsa heç vaxt silmə/toxunma!
if (!file_exists($json_file)) {
    file_put_contents($json_file, json_encode([]));
}

$keys_data = json_decode(file_get_contents($json_file), true);
if (!is_array($keys_data)) $keys_data = [];

// --- KÖHNƏ KEYLƏRİN QORUNMASI (JSON Fix) ---
$data_changed = false;
foreach ($keys_data as $k => $v) {
    if (!isset($v['status'])) { $keys_data[$k]['status'] = 'active'; $data_changed = true; }
    if (!isset($v['expire'])) { $keys_data[$k]['expire'] = 0; $data_changed = true; }
    if (!isset($v['max_devices'])) { $keys_data[$k]['max_devices'] = 1; $data_changed = true; }
    if (!isset($v['devices']) || !is_array($v['devices'])) { $keys_data[$k]['devices'] = []; $data_changed = true; }
    if (!isset($v['note'])) { $keys_data[$k]['note'] = ''; $data_changed = true; }
}
if ($data_changed) {
    file_put_contents($json_file, json_encode($keys_data, JSON_PRETTY_PRINT));
}

// --- Logout ---
if (isset($_GET['action']) && $_GET['action'] == 'logout') {
    unset($_SESSION['logged_in']);
    header("Location: admin.php");
    exit;
}

// --- Login ---
if (isset($_POST['login'])) {
    if ($_POST['password'] === $admin_pass) {
        $_SESSION['logged_in'] = true;
        header("Location: admin.php");
        exit;
    } else {
        $login_error = "Şifrə səhvdir!";
    }
}

// --- Login səhifəsi ---
if (!isset($_SESSION['logged_in']) || $_SESSION['logged_in'] !== true) {
    ?>
    <!DOCTYPE html>
    <html lang="az">
    <head>
        <meta charset="UTF-8">
        <title>Admin Login — DARK IOS</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            :root{
                --bg:#0a0a0f; --surface:#15151f; --surface-2:#1e1e2a;
                --border:#2a2a3a; --text:#e4e4e7; --text-dim:#8b8b9e;
                --accent:#7c5cff; --accent-hover:#6b4ce6;
                --danger:#ef4444;
            }
            *{box-sizing:border-box}
            body{
                background:var(--bg); color:var(--text);
                font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;
                display:flex; justify-content:center; align-items:center;
                min-height:100vh; margin:0; padding:20px;
            }
            .login-box{
                background:var(--surface); padding:36px 30px;
                border:1px solid var(--border); border-radius:14px;
                width:100%; max-width:360px; text-align:center;
                box-shadow:0 20px 60px rgba(0,0,0,.5);
            }
            .login-box h2{ margin:0 0 6px; font-size:22px; letter-spacing:1px; }
            .login-box .sub{color:var(--text-dim); font-size:13px; margin-bottom:24px;}
            input{
                width:100%; padding:12px 14px; margin:8px 0 16px;
                background:var(--surface-2); border:1px solid var(--border);
                color:var(--text); border-radius:8px; font-size:14px;
                transition:border .15s;
            }
            input:focus{outline:none; border-color:var(--accent);}
            button{
                width:100%; padding:12px; background:var(--accent);
                color:#fff; border:none; font-weight:600; font-size:14px;
                border-radius:8px; cursor:pointer; letter-spacing:.5px;
                transition:background .15s;
            }
            button:hover{background:var(--accent-hover);}
            .error{
                color:var(--danger); font-size:13px;
                background:rgba(239,68,68,.1); padding:10px;
                border-radius:8px; margin-bottom:16px;
                border:1px solid rgba(239,68,68,.3);
            }
        </style>
    </head>
    <body>
        <div class="login-box">
            <h2>DARK IOS</h2>
            <div class="sub">Admin Panel Girişi</div>
            <?php if(isset($login_error)) echo "<div class='error'>$login_error</div>"; ?>
            <form method="POST">
                <input type="password" name="password" placeholder="Admin şifrəsi" required autofocus>
                <button type="submit" name="login">GİRİŞ ET</button>
            </form>
        </div>
    </body>
    </html>
    <?php
    exit;
}

// --- Əməliyyatlar ---
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

        // Normal müddətlər
        if ($duration_type == '1D') { $expire_time = $now + 86400; $prefix = "DARKOS-1D-"; }
        elseif ($duration_type == '7D') { $expire_time = $now + (7 * 86400); $prefix = "DARKOS-7D-"; }
        elseif ($duration_type == '30D') { $expire_time = $now + (30 * 86400); $prefix = "DARKOS-30D-"; }
        elseif ($duration_type == 'LIFETIME') { $expire_time = 0; $prefix = "DARKOS-LIFETIME-"; }
        
        // Tester müddətləri (Xüsusi prefix)
        elseif ($duration_type == 'TEST_1D') { $expire_time = $now + 86400; $prefix = "DARKIOS-TESTERKEY-"; }
        elseif ($duration_type == 'TEST_7D') { $expire_time = $now + (7 * 86400); $prefix = "DARKIOS-TESTERKEY-"; }
        elseif ($duration_type == 'TEST_30D') { $expire_time = $now + (30 * 86400); $prefix = "DARKIOS-TESTERKEY-"; }
        elseif ($duration_type == 'TEST_LIFETIME') { $expire_time = 0; $prefix = "DARKIOS-TESTERKEY-"; }

        // Tester üçün 12 simvolluq random, normal üçün 8 simvol (random_bytes(4))
        if (strpos($duration_type, 'TEST_') !== false) {
            $random_part = strtoupper(substr(bin2hex(random_bytes(6)), 0, 12));
        } else {
            $random_part = strtoupper(bin2hex(random_bytes(4)));
        }
        
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
                if ($keys_data[$k]['expire'] > 0) $keys_data[$k]['expire'] += 86400;
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

// --- Status / müddət köməkçiləri ---
function key_status_badge($v) {
    if ($v['status'] == 'banned') {
        return '<span class="badge badge-danger">● Bloklanıb</span>';
    }
    if ($v['expire'] > 0 && $v['expire'] < time()) {
        return '<span class="badge badge-muted">● Vaxtı bitib</span>';
    }
    return '<span class="badge badge-success">● Aktiv</span>';
}

function key_time_left($v) {
    if ($v['expire'] == 0) return '<span class="badge badge-accent">∞ Sınırsız</span>';
    $diff = $v['expire'] - time();
    if ($diff <= 0) return '<span class="text-danger">Vaxtı bitib</span>';
    $days = ceil($diff / 86400);
    return '<span class="text-dim">' . $days . ' gün qaldı</span>';
}
?>
<!DOCTYPE html>
<html lang="az">
<head>
    <meta charset="UTF-8">
    <title>Admin Panel — DARK IOS</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        :root{
            --bg:#0a0a0f; --surface:#15151f; --surface-2:#1e1e2a;
            --border:#2a2a3a; --text:#e4e4e7; --text-dim:#8b8b9e;
            --accent:#7c5cff; --accent-hover:#6b4ce6;
            --success:#22c55e; --danger:#ef4444; --warning:#f59e0b;
        }
        *{box-sizing:border-box}
        body{
            background:var(--bg); color:var(--text);
            font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;
            margin:0; padding:24px 16px; line-height:1.5;
        }
        .container{max-width:900px; margin:0 auto;}

        /* Header */
        .header{
            display:flex; justify-content:space-between; align-items:center;
            margin-bottom:24px; flex-wrap:wrap; gap:12px;
        }
        .header h1{font-size:20px; margin:0; letter-spacing:.5px; white-space:nowrap;}
        .header h1 span{color:var(--accent);}
        .header-right{display:flex; gap:10px; align-items:center; flex-wrap:wrap;}
        
        /* Axtarış Qutusu */
        .search-box {
            position: relative;
            display: flex; align-items: center;
        }
        .search-box svg {
            position: absolute; left: 10px; width: 16px; height: 16px;
            fill: none; stroke: var(--text-dim); stroke-width: 2;
            stroke-linecap: round; stroke-linejoin: round;
        }
        .search-box input {
            padding: 8px 12px 8px 34px; font-size: 14px;
            background: var(--surface); border: 1px solid var(--border);
            color: var(--text); border-radius: 8px; transition: border .15s;
            width: 200px;
        }
        .search-box input:focus {
            outline: none; border-color: var(--accent);
        }
        
        .settings-btn, .logout-btn{
            color:var(--text-dim); text-decoration:none; font-size:14px;
            padding:8px 16px; border:1px solid var(--border);
            border-radius:8px; transition:all .15s; cursor:pointer;
            background:var(--surface); font-family:inherit; white-space:nowrap;
        }
        .settings-btn:hover{border-color:var(--accent); color:var(--accent);}
        .logout-btn{color:var(--danger); border-color:rgba(239,68,68,.3);}
        .logout-btn:hover{background:rgba(239,68,68,.1);}

        /* Modal Overlay & Animasiya */
        .modal-overlay {
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0, 0, 0, 0.7); backdrop-filter: blur(4px);
            display: flex; justify-content: center; align-items: center;
            z-index: 1000; opacity: 0; visibility: hidden;
            transition: opacity 0.25s ease, visibility 0.25s ease;
        }
        .modal-overlay.active { opacity: 1; visibility: visible; }
        
        .modal-content {
            background: var(--surface); border: 1px solid var(--border);
            border-radius: 14px; padding: 24px; width: 90%; max-width: 400px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.6);
            transform: scale(0.9) translateY(20px); opacity: 0;
            transition: transform 0.25s cubic-bezier(0.175, 0.885, 0.32, 1.275), opacity 0.25s ease;
        }
        .modal-overlay.active .modal-content { transform: scale(1) translateY(0); opacity: 1; }
        
        .modal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .modal-header h3 { margin: 0; font-size: 18px; color: var(--text); }
        .modal-close { background: none; border: none; color: var(--text-dim); font-size: 24px; cursor: pointer; line-height: 1; transition: color 0.15s; padding: 0; }
        .modal-close:hover { color: var(--text); }

        /* Danger zone inside modal */
        .danger-zone{
            border:1px solid rgba(239,68,68,.3);
            background:rgba(239,68,68,.05);
            padding:16px; border-radius:10px;
        }
        .danger-zone h4{color:var(--danger); margin:0 0 8px; font-size:14px;}
        .danger-zone p{color:var(--text-dim); font-size:13px; margin:0 0 14px;}
        .btn-danger-solid{background:var(--danger) !important; width: 100%;}
        .btn-danger-solid:hover{background:#dc2626 !important;}

        /* Cards */
        .card{
            background:var(--surface); border:1px solid var(--border);
            border-radius:14px; padding:22px; margin-bottom:20px;
        }
        .card h2{
            margin:0 0 18px; font-size:16px; font-weight:600;
            display:flex; align-items:center; justify-content:space-between;
            flex-wrap:wrap; gap:8px;
        }
        .card h2 .count{
            font-size:12px; color:var(--text-dim); font-weight:400;
            background:var(--surface-2); padding:4px 10px; border-radius:20px;
        }

        /* Form */
        .form-row{display:flex; gap:12px; flex-wrap:wrap; margin-bottom:12px;}
        .form-row > *{flex:1; min-width:140px;}
        input, select{
            width:100%; padding:11px 14px; background:var(--surface-2);
            border:1px solid var(--border); color:var(--text);
            border-radius:8px; font-size:14px; transition:border .15s;
        }
        input:focus, select:focus{outline:none; border-color:var(--accent);}
        input::placeholder{color:var(--text-dim);}
        button{
            padding:11px 20px; background:var(--accent); color:#fff;
            border:none; font-weight:600; font-size:14px; border-radius:8px;
            cursor:pointer; transition:background .15s;
        }
        button:hover{background:var(--accent-hover);}
        .btn-block{width:100%; margin-top:4px;}

        /* Key list */
        .key-item{
            background:var(--surface-2); border:1px solid var(--border);
            border-radius:10px; padding:16px; margin-bottom:12px;
            transition:border .15s;
        }
        .key-item:hover{border-color:#3a3a4a;}
        .key-head{
            display:flex; justify-content:space-between; align-items:flex-start;
            gap:12px; margin-bottom:10px; flex-wrap:wrap;
        }
        .key-code{
            font-family:ui-monospace,SFMono-Regular,Menlo,monospace;
            font-size:14px; font-weight:600; color:var(--text);
            word-break:break-all;
        }
        .key-note{color:var(--accent); font-size:13px; margin-left:6px; font-weight:400;}
        .key-meta{
            display:flex; gap:16px; flex-wrap:wrap;
            font-size:13px; color:var(--text-dim); margin-bottom:12px;
        }
        .key-meta strong{color:var(--text); font-weight:500;}

        /* Badges */
        .badge{
            display:inline-block; padding:3px 10px; border-radius:20px;
            font-size:12px; font-weight:500;
        }
        .badge-success{background:rgba(34,197,94,.15); color:var(--success);}
        .badge-danger{background:rgba(239,68,68,.15); color:var(--danger);}
        .badge-muted{background:rgba(139,139,158,.15); color:var(--text-dim);}
        .badge-accent{background:rgba(124,92,255,.15); color:var(--accent);}

        /* Actions */
        .actions{display:flex; gap:8px; flex-wrap:wrap;}
        .actions button{
            padding:7px 12px; font-size:12px; font-weight:500;
            background:var(--surface); border:1px solid var(--border);
            color:var(--text);
        }
        .actions button:hover{background:var(--surface-2); border-color:#3a3a4a;}
        .actions .btn-warning{color:var(--warning); border-color:rgba(245,158,11,.3);}
        .actions .btn-warning:hover{background:rgba(245,158,11,.1);}
        .actions .btn-danger{color:var(--danger); border-color:rgba(239,68,68,.3);}
        .actions .btn-danger:hover{background:rgba(239,68,68,.1);}
        .actions .btn-success{color:var(--success); border-color:rgba(34,197,94,.3);}
        .actions .btn-success:hover{background:rgba(34,197,94,.1);}

        /* Empty state */
        .empty{
            text-align:center; padding:40px 20px; color:var(--text-dim);
        }
        .empty .icon{font-size:40px; margin-bottom:12px; opacity:.5;}

        .text-danger{color:var(--danger);}
        .text-dim{color:var(--text-dim);}

        @media(max-width:600px){
            .form-row > *{min-width:100%;}
            .key-meta{gap:10px; font-size:12px;}
            .actions button{flex:1; min-width:calc(50% - 4px);}
            .search-box input { width: 120px; }
            .header-right { width: 100%; justify-content: space-between; }
        }
    </style>
</head>
<body>
<div class="container">

    <div class="header">
        <h1><span>DARK</span> IOS Admin</h1>
        <div class="header-right">
            <!-- Axtarış -->
            <div class="search-box">
                <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                <input type="text" id="searchInput" placeholder="Axtar..." onkeyup="filterKeys()">
            </div>
            
            <button type="button" class="settings-btn" onclick="openModal()">⚙️ Ayarlar</button>
            <a href="admin.php?action=logout" class="logout-btn">Çıxış →</a>
        </div>
    </div>

    <!-- Yeni key -->
    <div class="card">
        <h2>Yeni Key Yarat</h2>
        <form method="POST">
            <div class="form-row">
                <input type="text" name="note" placeholder="Qeyd (istifadəçi adı və s.)">
            </div>
            <div class="form-row">
                <input type="number" name="max_devices" value="1" min="1" placeholder="Maks cihaz">
                <select name="duration_type">
                    <option value="1D">1 Günlük</option>
                    <option value="7D">7 Günlük</option>
                    <option value="30D">30 Günlük</option>
                    <option value="LIFETIME">Sınırsız (Lifetime)</option>
                    <option disabled>──────────</option>
                    <option value="TEST_1D">1 Günlük (Tester)</option>
                    <option value="TEST_7D">7 Günlük (Tester)</option>
                    <option value="TEST_30D">30 Günlük (Tester)</option>
                    <option value="TEST_LIFETIME">Lifetime (Tester)</option>
                </select>
            </div>
            <div class="form-row">
                <input type="text" name="custom_key" placeholder="Özəl key (boş = avtomatik)">
            </div>
            <button type="submit" name="create_key" class="btn-block">+ Key Yarat</button>
        </form>
    </div>

    <!-- Key list -->
    <div class="card">
        <h2>
            Mövcud Keylər
            <span class="count" id="keyCount"><?= count($keys_data) ?> key</span>
        </h2>

        <?php if (count($keys_data) === 0): ?>
            <div class="empty">
                <div class="icon">🔑</div>
                <div>Hələ heç bir key yaratmamısınız</div>
            </div>
        <?php else: ?>
            <div id="noResults" class="empty" style="display:none;">
                <div class="icon">🔍</div>
                <div>Axtarışınıza uyğun key tapılmadı</div>
            </div>
            
            <div id="keysContainer">
            <?php foreach($keys_data as $k => $v): ?>
                <?php
                    $is_banned = ($v['status'] == 'banned');
                ?>
                <div class="key-item" data-key="<?= htmlspecialchars(strtolower($k)) ?>" data-note="<?= htmlspecialchars(strtolower($v['note'])) ?>">
                    <div class="key-head">
                        <div>
                            <span class="key-code"><?= htmlspecialchars($k) ?></span>
                            <?php if(!empty($v['note'])): ?>
                                <span class="key-note">— <?= htmlspecialchars($v['note']) ?></span>
                            <?php endif; ?>
                        </div>
                        <?= key_status_badge($v) ?>
                    </div>
                    <div class="key-meta">
                        <span>Müddət: <?= key_time_left($v) ?></span>
                        <span>Cihaz: <strong><?= count($v['devices']) ?>/<?= $v['max_devices'] ?></strong></span>
                    </div>
                    <div class="actions">
                        <form method="POST"><input type="hidden" name="key_id" value="<?= htmlspecialchars($k) ?>"><input type="hidden" name="sub_action" value="reset_hwid"><button type="submit" name="action_key" class="btn-warning">HWID Sıfırla</button></form>
                        <form method="POST"><input type="hidden" name="key_id" value="<?= htmlspecialchars($k) ?>"><input type="hidden" name="sub_action" value="block"><button type="submit" name="action_key" class="btn-danger"><?= $is_banned ? 'Aç' : 'Blokla' ?></button></form>
                        <form method="POST"><input type="hidden" name="key_id" value="<?= htmlspecialchars($k) ?>"><input type="hidden" name="sub_action" value="add_time"><button type="submit" name="action_key" class="btn-success">+1 Gün</button></form>
                        <form method="POST"><input type="hidden" name="key_id" value="<?= htmlspecialchars($k) ?>"><input type="hidden" name="sub_action" value="limit_inc"><button type="submit" name="action_key" class="btn-warning">+Cihaz</button></form>
                        <form method="POST" onsubmit="return confirm('Bu key silinsin?');"><input type="hidden" name="key_id" value="<?= htmlspecialchars($k) ?>"><input type="hidden" name="sub_action" value="delete"><button type="submit" name="action_key" class="btn-danger">Sil</button></form>
                    </div>
                </div>
            <?php endforeach; ?>
            </div>
        <?php endif; ?>
    </div>

</div>

<!-- Ayarlar Modalı (Popup) -->
<div id="settingsModal" class="modal-overlay" onclick="closeModal(event)">
    <div class="modal-content" onclick="event.stopPropagation()">
        <div class="modal-header">
            <h3>⚙️ Ayarlar</h3>
            <button type="button" class="modal-close" onclick="closeModal(event)">&times;</button>
        </div>
        
        <div class="settings-body">
            <?php if (count($keys_data) > 0): ?>
            <div class="danger-zone">
                <h4>⚠ Təhlükəli Zona</h4>
                <p>Bu əməliyyat geri qaytarıla bilməz. Bütün keylər birdəfəlik silinəcək.</p>
                <form method="POST" onsubmit="return confirm('BÜTÜN keylər silinəcək. Əminsiniz?');">
                    <button type="submit" name="delete_all" class="btn-danger-solid">Bütün Keyləri Sil</button>
                </form>
            </div>
            <?php else: ?>
                <p style="color:var(--text-dim); font-size:14px; text-align:center; margin: 20px 0;">Hazırda silinəcək heç bir key yoxdur.</p>
            <?php endif; ?>
        </div>
    </div>
</div>

<script>
    // Modal funksiyaları
    function openModal() {
        document.getElementById('settingsModal').classList.add('active');
    }

    function closeModal(event) {
        if (event.target.id === 'settingsModal' || event.target.classList.contains('modal-close') || event.target.tagName === 'BUTTON') {
            document.getElementById('settingsModal').classList.remove('active');
        }
    }

    // Axtarış (Filtr) funksiyası
    function filterKeys() {
        var input = document.getElementById('searchInput');
        var filter = input.value.toLowerCase();
        var items = document.querySelectorAll('.key-item');
        var visibleCount = 0;
        
        items.forEach(function(item) {
            var keyName = item.getAttribute('data-key');
            var noteName = item.getAttribute('data-note');
            
            if (keyName.includes(filter) || noteName.includes(filter)) {
                item.style.display = '';
                visibleCount++;
            } else {
                item.style.display = 'none';
            }
        });
        
        var countEl = document.getElementById('keyCount');
        if(countEl) countEl.innerText = visibleCount + ' key';
        
        var noRes = document.getElementById('noResults');
        if(noRes) {
            if (visibleCount === 0 && items.length > 0) {
                noRes.style.display = 'block';
            } else {
                noRes.style.display = 'none';
            }
        }
    }
</script>
</body>
</html>
