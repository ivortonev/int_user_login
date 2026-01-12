<?php
$servername = "localhost";
$username = "SQL_USER_LOGIN";
$password = "SQL_USER_PASSWD";
$dbname = "SQL_DATABASE";
$session_time = "4";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}

?>

