<?php
session_start();
include 'db_connection.php';

if (!isset($_SESSION["customer"])) {
    header("Location: login.html");
    exit();
}

if (isset($_POST["pet_id"])) {
    $pet_id = $_POST["pet_id"];
    $customer_email = $_SESSION["customer"];

    // Fetch customer ID
    $query = "SELECT cs_id FROM Customers WHERE email='$customer_email'";
    $result = $conn->query($query);
    $row = $result->fetch_assoc();
    $cs_id = $row["cs_id"];

    // Insert into Sales
    $query = "INSERT INTO Sales (cs_id, payment_id, date) VALUES ('$cs_id', 1, NOW())";
    $conn->query($query);
    $sale_id = $conn->insert_id;

    // Insert into Sold_Pets
    $query = "INSERT INTO Sold_Pets (sale_id, pet_id) VALUES ('$sale_id', '$pet_id')";
    $conn->query($query);

    echo "Pet purchased successfully! <a href='dashboard.php'>Back to Dashboard</a>";
}
?>
