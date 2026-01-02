<?php

require_once './conf.php';

$login=$_GET['login'];

$sql_show_user_ips = "select source_ip from login where login = '$login';";
$result_show_user_ips = $conn->query($sql_show_user_ips);

if ($result_show_user_ips->num_rows > 0) {
	while($row = $result_show_user_ips->fetch_assoc()) {
		echo $row["source_ip"] . "\n";
	}
} else {
	echo "99.99.99.99";
}

$conn->close();

?>

