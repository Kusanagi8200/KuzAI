<?php
header('Content-Type: application/json');

$output = shell_exec('nvidia-smi --query-gpu=name,memory.total,memory.used,memory.free,temperature.gpu,utilization.gpu --format=csv,noheader,nounits');

$gpus = [];
$lines = explode("\n", trim($output));

foreach ($lines as $line) {
    list($name, $total, $used, $free, $temp, $util) = array_map('trim', explode(',', $line));
    $gpus[] = [
        'name' => $name,
        'memory_total' => (int)$total,
        'memory_used' => (int)$used,
        'memory_free' => (int)$free,
        'temperature' => (int)$temp,
        'utilization' => (int)$util
    ];
}

echo json_encode($gpus);
