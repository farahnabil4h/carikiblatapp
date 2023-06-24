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
$locationid = $_POST['locationId'];
$sqlupdate = "UPDATE `tbl_locations` SET `location_name`='$locationName',`location_latitude`='$latitude', `location_longitude`='$longitude' WHERE location_id = '$locationid'";

if ($conn->query($sqlupdate) === TRUE) {
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