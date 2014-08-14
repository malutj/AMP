<?php
//Turn on error reporting
ini_set('display_errors', 'On');

//include the database connection info
include('database_connect.php');

//global vars
$app_code = "j5K4F98j3vnME57G10f";
$common_dir = "../client_files/common";
$response = array();
$common_file_list = array();
$unique_file_list = array();

//verify that request came from app
if(empty($_POST['app_code']) || $_POST['app_code'] != $app_code){
    echo("Sorry, we don't recognize the origination of this request.");
    die();
}

//fetch list of all common files and save paths and mod dates
$common_file_list = get_file_list($common_dir);

//create PDO object

//get directory location for this client

//fetch list of all client-specific files save paths and mod dates

//overwrite common files with client-specific files where required

//return client file list


function get_file_list($dir){
    //get list of all files/directories inside $dir
    $f = array_diff(scandir($dir), array('..', '.'));
    $dir_list = array();
    //iterate through file array and dig out each directory
    do{
        foreach($f as &$entry){
            if(is_dir($dir.$entry)){
                array_push
            }
        }
    }while(count($dir_list));
    
    
}
?>
