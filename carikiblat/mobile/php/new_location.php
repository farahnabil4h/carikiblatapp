<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
}

include_once("dbconnect.php");
$locationName = addslashes($_POST['locationName']);
$latitude = $_POST['latitude'];
$longitude = $_POST['longitude'];
$sqlinsert = "INSERT INTO `tbl_locations`(`location_name`, `location_latitude`, `location_longitude`) VALUES ('$locationName','$latitude','$longitude')";

if ($conn->query($sqlinsert) === TRUE) {
    $response = array('status' => 'success', 'data' => null);
    sendJsonResponse($response);
} else {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>