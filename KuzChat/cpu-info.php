<?php
header('Content-Type: application/json');

// Récupération du modèle de CPU
$cpuModel = shell_exec("lscpu | grep 'Model name' | sed 's/Model name: *//'");
$cpuCores = shell_exec("nproc");  // Nombre de cœurs CPU
$cpuSpeed = shell_exec("lscpu | grep 'CPU MHz' | sed 's/CPU MHz: *//'");
$cpuArchitecture = shell_exec("lscpu | grep 'Architecture' | sed 's/Architecture: *//'");

echo json_encode([
    "cpu_model" => trim($cpuModel),
    "cpu_cores" => trim($cpuCores),
    "cpu_speed" => trim($cpuSpeed) . " MHz",
    "cpu_architecture" => trim($cpuArchitecture)
]);
?>
