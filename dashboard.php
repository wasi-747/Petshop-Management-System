<?php
session_start();
include 'db_connection.php';

if (!isset($_SESSION["customer"])) {
    header("Location: login.html");
    exit();
}

echo "<h2>Welcome, " . $_SESSION["customer"] . "</h2>";

$query = "SELECT * FROM Pets ORDER BY cost DESC";
$result = $conn->query($query);

echo "<h2>Available Pets</h2>";
while ($row = $result->fetch_assoc()) {
    echo "Pet ID: " . $row["pet_id"] . " - Category: " . $row["pet_category"] . " - Price: " . $row["cost"];
    echo "<form method='post' action='buy_pet.php'>
            <input type='hidden' name='pet_id' value='" . $row["pet_id"] . "'>
            <button type='submit'>Buy Now</button>
          </form><br>";
}
?>

<a href="logout.php">Logout</a>
