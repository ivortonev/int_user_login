<?php

require_once './conf.php';

$run_time = time();

// Select para verificar se ja existe o registro e ainda esta valido
$sql_expire_session = "DELETE FROM login WHERE expire_time < $run_time;";
$result_expire_session = $conn->query($sql_expire_session);
$conn->close();

?>

