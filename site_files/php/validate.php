<?php
session_start();            //start the session
include('db_connect.php');  //this holds all the database connection info

//Turn error reporting on
ini_set('display_errors', 'On');

//get the request type
$request_type = (empty($_GET['request_type'])) ? $_POST["request_type"] : $_GET['request_type'];

//create response array
$return = array();

/**********************************************
 *              LOGIN REQUEST	
 *********************************************/
if($request_type==="login"){
    //Connect to the database
    try {
      $pdo = new PDO($dbinfo, $dbuser, $dbpass);
    } 
    catch (PDOException $e) {
      $return['status'] = 'error';
      $return['msg'] = "Connection problem [".$e->getMessage()."]";
      echo json_encode($return);
      exit();
    }
    //Set PDO to throw exceptions
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    //Username and password from POST...stripped of tags
    $username = strip_tags($_POST["username"]);
    $password = $_POST["password"];

    //Get all records with that username
    $query = "SELECT * FROM users WHERE username = '$username'";
    $stmt = $pdo->prepare($query);
  
    //make sure query is successful
    try{
      $stmt->execute();
      $result = $stmt->fetchAll();
      
      //if the query returned 0 results then the user isn't in the database
      if(count($result) > 0){
        if($result[0]['password'] === $password){
          //set session variable
          $_SESSION["current_user"] = $username;
          $return['status'] = 'success';
          echo json_encode($return);
          die();
        }
      }
      $return['status'] = 'error';
      $return['msg'] = 'Username or password is incorrect';
    }
    //query failed
    catch (PDOException $e){
      $return['status'] = 'error';
      $return['msg'] = $e->getMessage();
    }
    echo json_encode($return);
    die();
}
/**********************************************
 *          VALIDATION REQUEST	
 *********************************************/
elseif($request_type==="validate"){
    //If someone is logged in
    if(isset($_SESSION["current_user"])){
        $return['status'] = 'logged in';
    }
    //Nobody is logged in
    else{
        $return['status'] = 'not logged in';
    }
    echo json_encode($return);
    die();
}

/**********************************************
 *              LOGOUT REQUEST	
 *********************************************/
elseif($request_type==="logout"){
    session_destroy();
}
?>
