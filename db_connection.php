<?php
$servername = "localhost";
$username = "root";  // Change if using a different MySQL user
$password = "";      // Change if using a MySQL password
$dbname = "petshop_management";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>
