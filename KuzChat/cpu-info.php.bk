<?php
header('Content-Type: application/json');

$cpuModel = shell_exec("lscpu | grep 'Model name' | sed 's/Model name: *//'");
$cpuCores = shell_exec("nproc");
$cpuArchitecture = shell_exec("lscpu | grep 'Architecture' | sed 's/Architecture: *//'");

echo json_encode([
    "cpu_model" => trim($cpuModel),
    "cpu_cores" => trim($cpuCores),
    "cpu_architecture" => trim($cpuArchitecture)
]);
?>
