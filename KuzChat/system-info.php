<?php
header('Content-Type: application/json');

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
