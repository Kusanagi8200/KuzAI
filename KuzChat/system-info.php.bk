<?php
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'];

    if ($action === 'list') {
        echo shell_exec('./ollama-wrapper.sh list');
        exit;
    } elseif ($action === 'start' && isset($_POST['model'])) {
      $model = escapeshellarg($_POST['model']);
      $output = shell_exec("./ollama-wrapper.sh run $model");
      echo "✅ Le modèle " . htmlspecialchars($_POST['model']) . " a été démarré.";
      exit;
    } elseif ($action === 'stop' && isset($_POST['model'])) {
      $model = escapeshellarg($_POST['model']);
      $output = shell_exec("./ollama-wrapper.sh stop $model");
      echo "🛑 Le modèle " . htmlspecialchars($_POST['model']) . " a été arrêté.";
      exit;
    } elseif ($action === 'status' && isset($_POST['model'])) {
        echo shell_exec('./ollama-wrapper.sh status ' . escapeshellarg($_POST['model']));
        exit;
    }

    echo json_encode(["error" => "invalid action"]);
    exit;
}

$ip = trim(shell_exec("hostname -I | awk '{print $1}'"));

$rawOutput = shell_exec("/usr/local/bin/ollama-wrapper.sh 2>&1");
$model = "NOT DETECTED";
$lines = explode("\n", trim($rawOutput));

foreach ($lines as $line) {
    if (stripos($line, 'NAME') === 0) continue;
    if (preg_match('/^\s*(\S+)/', $line, $matches)) {
        $model = $matches[1];
        break;
    }
}

$dateTime = [
    "date" => date('Y/m/d'),
    "time" => date('H:i:s')
];

echo json_encode([
    "ip" => $ip,
    "model" => $model,
    "date" => $dateTime['date'],
    "time" => $dateTime['time']
]);
