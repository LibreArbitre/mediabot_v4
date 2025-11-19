<?php
// Usage: php set_password.php <username> <new_password>
// This script should be run from the htdocs/mbadm/tools/ directory.

// We are in tools/, so we need to go up two directories to reach the root of htdocs
require_once('../../includes/conf/config.php');
require_once('../../includes/functions/dbConnect.php');

if ($argc !== 3) {
    echo "Usage: php set_password.php <username> <new_password>\n";
    exit(1);
}

$username = $argv[1];
$new_password = $argv[2];

// Hash the new password securely
$hashed_password = password_hash($new_password, PASSWORD_DEFAULT);

if ($hashed_password === false) {
    echo "Error: Failed to hash the password.\n";
    exit(1);
}

// Prepare the update query
$stmt = mysqli_prepare($link, "UPDATE USER SET password = ? WHERE nickname = ?");

if ($stmt === false) {
    echo "Error preparing statement: " . mysqli_error($link) . "\n";
    exit(1);
}

mysqli_stmt_bind_param($stmt, "ss", $hashed_password, $username);

// Execute the query
if (mysqli_stmt_execute($stmt)) {
    if (mysqli_stmt_affected_rows($stmt) > 0) {
        echo "Password for user '$username' has been updated successfully.\n";
    } else {
        echo "User '$username' not found or password is the same.\n";
    }
} else {
    echo "Error executing statement: " . mysqli_stmt_error($stmt) . "\n";
}

mysqli_stmt_close($stmt);
mysqli_close($link);

?>