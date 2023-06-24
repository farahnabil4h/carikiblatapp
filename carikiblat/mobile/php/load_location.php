<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
}

include_once("dbconnect.php");
$search = $_POST['search'];
$sqlloadlocation = "SELECT * FROM tbl_locations WHERE location_name LIKE '%$search%'";
$result = $conn->query($sqlloadlocation);

if ($result-> num_rows > 0){ 
    $locations["locations"] = array();
    while($row = $result->fetch_assoc()) {
        $locationlist = array ();
        $locationlist['location_id']=$row['location_id'];
        $locationlist['location_name']=$row['location_name'];
        $locationlist['location_latitude']=$row['location_latitude'];
        $locationlist['location_longitude']=$row['location_longitude'];
        array_push($locations["locations"],$locationlist);
    }
    $response = array('status' => 'success', 'data' => $locations);
    sendJsonResponse($response);
}
else {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

?>