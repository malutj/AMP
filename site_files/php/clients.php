<?php
session_start();
include('db_connect.php');

//connect to database server
mysql_connect($dbhost, $dbuser, $dbpass) 
	or die ("Unable to connect to database! Please try again later.");
//select the correct database
mysql_select_db($dbname)
	or die ("Unable to find database!");
//set the request type
$request_type = $_POST["requestType"];

//determine the request type and call the appropriate function to handle the request
if($request_type==="load"){fetch_clients();}
elseif($request_type==="add"){add_client();}
elseif($request_type==="delete"){delete_client();}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Desc: Fetches all the client data
* Param: void
* Return: void
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
function fetch_clients(){
	$query = "SELECT * FROM client_table";
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

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Desc: Creates a new client entry
* Param: void
* Return: void
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
function add_client(){
    //create client variables
    $client_name = strip_tags($_POST["client_name"]);
    $client_code = generate_client_code($client_name);  //generate the client code
    //create and run the query
    $query = "INSERT INTO client_table (name, code) VALUES ('$client_name', '$client_code')";
	$result = mysql_query($query);  
	if($result){
	    //create the new directory
	    generate_client_directory($client_name, $client_code);
		$return = array('status'=>'success', 'code'=>$client_code);
		echo json_encode($return);
	}
	else{
		$return = array('status'=>'fail');
		echo json_encode($return);
	}
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Desc: Generates a unique client code
* Param: client name
* Return: client code
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
function generate_client_code($name){
    $prefix = 0;
    $code = "";
    do{
        $prefix++;
        $code = substr(md5($prefix.$name) , 0, 6);
        //see if the code already exists in the database
    }while(1==0);
    return $code;
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Desc: Creates a directory for the client
* Param: client name, client code
* Return: void
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
function create_client_directory($name, $code){
    //dirname(dirname(__FILE__));
    $dir_path = "../client_files/".$name."_".$code;
    if(!file_exists($dir_path)){
        mkdir($dir_path);
    }
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Desc: Deletes a client entry
* Param: void
* Return: void
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
function delete_client(){
    $client_id = $_POST["client_id"];
    $query = "DELETE FROM client_table WHERE client_id = $client_id";
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
