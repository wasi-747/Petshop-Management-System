<?php
include 'db_connection.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $fname = $_POST["fname"];
    $lname = $_POST["lname"];
    $email = $_POST["email"];
    $password = password_hash($_POST["password"], PASSWORD_BCRYPT); // Secure password hashing

    $query = "INSERT INTO Customers (cs_fname, cs_lname, email, password) VALUES ('$fname', '$lname', '$email', '$password')";
    if ($conn->query($query) === TRUE) {
        echo "Registration successful! <a href='login.html'>Login here</a>";
    } else {
        echo "Error: " . $conn->error;
    }
}
?>
