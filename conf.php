<?php
$servername = "localhost";
$username = "user_login";
$password = "user_login";
$dbname = "int_user_login";
$session_time = "4";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}

?>

