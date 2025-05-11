<?php
header('Content-Type: application/json');

$ollama_bin = '/usr/local/bin/ollama';
$command = "sudo -u www-data $ollama_bin ls 2>&1";

exec($command, $output, $status);

if ($status !== 0) {
    echo json_encode(['error' => 'Command failed', 'output' => $output]);
    exit;
}

$models = [];

foreach ($output as $index => $line) {
    if ($index === 0) continue; 
    if (trim($line) === '') continue;

    $parts = preg_split('/\s{2,}/', $line);
    if (count($parts) >= 4) {
        $models[] = [
            'name' => $parts[0],
            'id' => $parts[1],
            'size' => $parts[2],
            'modified' => $parts[3]
        ];
    }
}

echo json_encode(['models' => $models]);
