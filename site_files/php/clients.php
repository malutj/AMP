<?php
session_start();            //start the session	
include('db_connect.php');  //this holds all the database connection info
include('global.php');       

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
if($request_type==="validate"){validate_client();}
elseif($request_type==="load"){load_clients();}
elseif($request_type==="add"){add_client();}
elseif($request_type==="delete"){delete_client();}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Desc: Validates a client code
* Param: void
* Return: void
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
function validate_client(){
    $clientCode = $_POST["clientCode"];
    global $pdo;
    
    //Get all records with that username
    $query = "SELECT * FROM clients WHERE client_code = '$clientCode'";
    $stmt = $pdo->prepare($query);
  
    //make sure query is successful
    try{
      $stmt->execute();
      $result = $stmt->fetchAll();
      
      //if the query returned 0 results then the user isn't in the database
      if(count($result) > 0){
        //set session variable
        $return['status'] = 'success';
        echo json_encode($return);
        exit();
      }
      $return['status'] = 'error';
      $return['msg'] = 'Client Code is unrecognized';
    }
    //query failed
    catch (PDOException $e){
      $return['status'] = 'error';
      $return['msg'] = $e->getMessage();
    }
    echo json_encode($return);
    exit();
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Desc: Fetches all the client data
* Param: void
* Return: void
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
function load_clients(){
    $client_list = array();
    global $pdo;
    try{
        //Create the query
        $query = "SELECT * FROM clients";
        $stmt = $pdo->prepare($query);
        //Execute the query
        $result = $stmt->execute();
        if($result){
            while($row=$stmt->fetch(PDO::FETCH_ASSOC)){
                array_push($client_list, $row);
            }
        }
        $response['status'] = 'success';
        $response['client_list'] = $client_list;
    }
    catch(PDOException $e){
        $response['status'] = 'fail';
        $response['msg'] = $e->getMessage();
    }
    echo json_encode($response);
    die();
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Desc: Creates a new client entry
* Param: void
* Return: void
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
function add_client(){
    global $pdo;
    //Create client variables
    $client_name = strip_tags($_POST["client_name"]);   //strip tags from client name
    $client_code = generate_client_code($client_name);  //generate the client code
    try{
        //Create the query
        $query = "INSERT INTO clients (client_name, client_code) VALUES (:client_name, :client_code)";
        $stmt = $pdo->prepare($query);
        //Execute query
        $result = $stmt->execute(array(':client_name'=>$client_name, ':client_code'=>$client_code));
    	 
    	if($result){
    	    //create the new directory
    	    create_client_directory($client_name);
    		$response['status'] = 'success';
            $response['cid'] = $pdo->lastInsertId();
    		$response['code'] = $client_code;
    	}
    }
    catch(PDOException $e){
        $response['status'] = 'fail';
        if($stmt->errorCode() == "23000"){
            $response['msg'] = "That client name already exists";
        }
        else{
            $response['msg'] = $e->getMessage();
        }
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
    }while(client_code_exists($code));
    return $code;
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Desc: Creates a directory for the client
* Param: client name, client code
* Return: void
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
function create_client_directory($name){
    global $main_dir;
    //dirname(dirname(__FILE__));
    $name_temp = str_replace(" ", "_", $name); //Replace all spaces in name with underscore
    $dir_path = $main_dir.'/'.$name_temp;
    if(!file_exists($dir_path)){
        mkdir($dir_path, 0777, true);
    }
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Desc: Deletes a client entry
* Param: void
* Return: void
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
function delete_client(){
    global $pdo;
    $client_id = $_POST["client_id"];

    try{
        //Create the query
    	$query = "DELETE FROM clients WHERE client_id = :client_id";
    	$stmt = $pdo->prepare($query);
    	$stmt->bindParam(':client_id', $client_id);

        //Execute the query
    	$result = $stmt->execute();
    	if($result){
    		$reponse['status'] = 'success';
    	}
    	else{
    	    $response['status'] = 'fail';
    	    $response['msg'] = "There was an error deleting this client";
    	}
    }
    catch(PDOException $e){
        $response['status'] = 'fail';
    	$response['msg'] = $e->getMessage();
    }
    
    echo json_encode($response);
    die();
}

function client_code_exists($code){
    global $pdo;
    try{
        //Create the query
        $query = "SELECT client_id FROM clients WHERE client_code = :code";
        $stmt = $pdo->prepare($query);

        //Execute the query
        $result = $stmt->execute();
        if($result){
            if(count($stmt->fetch(PDO::FETCH_NUM)) > 0) return true;
            return false;
        }
    }
    catch(PDOException $e){
        // not really sure what error handling we should do here
        return false;
    }
}
?>
