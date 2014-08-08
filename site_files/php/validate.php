<?php
session_start();		    //start the session
include('db_connect.php');	//this holds all the database connection info

/**********************************************
 *		LOGIN REQUEST	
 *********************************************/
if($_POST["requestType"]==="login"){
    //Connect to database server
    mysql_connect($dbhost, $dbuser, $dbpass) 
        or die ("Unable to connect to database! Please try again later.");
	//Select the correct database
	mysql_select_db($dbname)
		or die ("Unable to find database!");

	//Username and password from POST...stripped of tags
	$username = strip_tags($_POST["username"]);
	$password = strip_tags($_POST["password"]);

	//Get all records with that username
	$query = "SELECT * FROM user_table WHERE username = '$username'";
	$result = mysql_query($query);

	//Query successful
	if ($result) {
		//If a matching username is found
		while($row = mysql_fetch_array($result)){
			$name = $row["username"];
			$userID = $row["user_id"];
			//If the passwords match
			//if(password_verify($password, $row["password"]))
			if($password === $row["password"]){
				$_SESSION["currentUser"] = $name;
				$_SESSION["userID"] = $userID;
				$return = array('status'=>'success','currentUser'=>$name);
				echo json_encode($return);
				die();
			}
		}
		//Username wasn't found or no matching passwords were found
		$return = array('status'=>'Incorrect username or password');
		echo json_encode($return);
		die();
	}
	//Query unsuccessful
	else{
		$return = array("status"=>"There was an error querying the database");
		echo json_encode($return);
		die();
	}
}
/**********************************************
 *		VALIDATION REQUEST	
 *********************************************/
elseif($_POST["requestType"]==="validate"){
	$return;
	//If someone is logged in
	if(isset($_SESSION["currentUser"])){
		$return = array("status"=>"logged in", "username"=>$_SESSION["currentUser"], "userID"=>$_SESSION["userID"]);
		
	}
	//Nobody is logged in
	else{
		$return = array("status"=>"not logged in");
	}
	echo json_encode($return);
}

/**********************************************
 *		LOGOUT REQUEST	
 *********************************************/
elseif($_POST["requestType"]==="logout"){
	session_destroy();
}
?>
