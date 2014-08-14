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
if($request_type==="load"){load_clients($pdo);}
elseif($request_type==="add"){add_client($pdo);}
elseif($request_type==="delete"){delete_client($pdo);}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Desc: Fetches all the client data
* Param: void
* Return: void
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
function load_clients($pdo){
    $client_list = array();
    try{
        //Execute the query
        $result = $stmt = $pdo->query("SELECT * FROM clients");
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
function add_client($pdo){
    //Create client variables
    $client_name = strip_tags($_POST["client_name"]);   //strip tags from client name
    $client_code = generate_client_code($client_name);  //generate the client code
    try{
        //Create the query
        $query = "INSERT INTO clients (name, code) VALUES (:client_name, :client_code)";
        $stmt = $pdo->prepare($query);
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
    $name_temp = str_replace(" ", "_", $name); //Replace all spaces in name with underscore
    $dir_path = "../client_files/".$name_temp."_".$code;
    if(!file_exists($dir_path)){
        mkdir($dir_path);
    }
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Desc: Deletes a client entry
* Param: void
* Return: void
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
function delete_client($pdo){
    $client_id = $_POST["client_id"];
    try{
    	$query = "DELETE FROM client_table WHERE client_id = :client_id";
    	$stmt = $pdo->prepare($query);
    	$stmt->bindParam(':client_id', $client_id);
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
?>
