<?php
header('Content-Type: application/json');

// Adresse IP
$ip = trim(shell_exec("hostname -I | awk '{print $1}'"));

// Appel via wrapper shell
$rawOutput = shell_exec("/usr/local/bin/ollama-wrapper.sh 2>&1");

// Analyse du modèle
$model = "Non détecté";
$lines = explode("\n", trim($rawOutput));

foreach ($lines as $line) {
    if (stripos($line, 'NAME') === 0) continue; // ignorer en-tête
    if (preg_match('/^\s*(\S+)/', $line, $matches)) {
        $model = $matches[1]; // exemple : "KuzTrash:latest"
        break;
    }
}

// Format date/heure
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
