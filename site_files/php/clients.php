<?php
session_start();            //start the session	
include('db_connect.php');  //this holds all the database connection info

//Turn error reporting on
ini_set('display_errors', 'On');

//create response array
$response = array();

//Connect to the database
try {
  $pdo = new PDO($dbinfo, $dbuser, $dbpass);
} 
catch (PDOException $e) {
  $response['status'] = 'error';
  $response['msg'] = "Connection problem [".$e->getMessage()."]";
  echo json_encode($response);
  exit();
}
//Set PDO to throw exceptions
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

//get the request type
$request_type = (empty($_GET['request_type'])) ? $_POST["request_type"] : $_GET['request_type'];

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
		$response = array("status"=>"success", "data"=>$data);
		echo json_encode($response);
	}
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Desc: Creates a new client entry
* Param: void
* Return: void
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
function add_client(){
    //Create client variables
    $client_name = strip_tags($_POST["client_name"]);   //strip tags from client name
    $client_code = generate_client_code($client_name);  //generate the client code
    try{
        //Create the query
        $query = "INSERT INTO clients (name, code) VALUES (:client_name, :client_code)";
        $stmt = $pdo->prepare($query);
        //Start PDO transaction
        $pdo->beginTransaction();
        //Execute query
        $result = $stmt->execute(array(':client_name'=>$client_name, ':client_code'=>$client_code));
    	 
    	if($result){
    	    //create the new directory
    	    generate_client_directory($client_name, $client_code);
    		$response['status'] = 'success';
    		$response['code'] = $client_code;
    	}
    	else{
    		if($stmt->errorCode() == "23000"){
    		    $response['status'] = 'fail';
                $return['msg'] = "That client name already exists";
            }
    	}
    }
    catch(PDOException $e){
        $response['status'] = 'fail';
        $response['msg'] = $e->getMessage();
    }
    echo json_encode($response);
    die();
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
		$response = array("status"=>"success");
		echo json_encode($response);
	}
	else{
		$response = array("status"=>"fail");
		echo json_encode($response);
	}
}
?>
