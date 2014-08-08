<?php
session_start();
include('db_connect.php');

//Connect to database server
mysql_connect($dbhost, $dbuser, $dbpass) 
	or die ("Unable to connect to database! Please try again later.");
//Select the correct database
mysql_select_db($dbname)
	or die ("Unable to find database!");

if($_POST["requestType"]==="load"){
	$userID = $_SESSION["userID"];
	$query = "SELECT * FROM client_table WHERE user_id = '$userID'";
	$result = mysql_query($query);
	if($result){
		$data = array();
		while($row = mysql_fetch_array($result)){
			array_push($data, $row);
		}
		$return = array("status"=>"success", "data"=>$data);
		echo json_encode($return);
	}
}
elseif($_POST["requestType"]==="add"){
	$query = "INSERT INTO todo_table (user_id, todo_text) VALUES ('$_SESSION[userID]', '$_POST[todo_text]')";
	$result = mysql_query($query);
	if($result){
		$return = array('status'=>'success');
		echo json_encode($return);
	}
	else{
		$return = array('status'=>'fail');
		echo json_encode($return);
	}
}
elseif($_POST["requestType"]==="delete"){
	$query = "DELETE FROM client_table WHERE client_id = '$_POST[client_id]'";
	if(mysql_query($query)){
		$return = array("status"=>"success");
		echo json_encode($return);
	}
	else{
		$return = array("status"=>"fail");
		echo json_encode($return);
	}
}
?>
