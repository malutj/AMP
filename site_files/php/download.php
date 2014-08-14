<?php
//Turn on error reporting
ini_set('display_errors', 'On');

//global variables
$app_code = "j5K4F98j3vnME57G10f";
$dir = "../client_files/";

//verify that request came from app
if(empty($_POST['app_code']) || $_POST['app_code'] != $app_code){
    echo("Sorry, we don't recognize the origination of this request.");
    die();
}

//get POST variables
$f = $dir.$_POST['file'];

//send the file
if (file_exists($f)){
    //create the header
    header('Content-Description: File Transfer');
    header('Content-Type: application/octet-stream');
    header('Content-Disposition: attachment; filename='.basename($f));
    header('Content-Transfer-Encoding: binary');
    header('Expires: -1');
    header('Cache-Control: no-cache');
    header('Pragma: no-cache');
    header('Content-Length: ' . filesize($f));
    ob_clean();
    flush();
    readfile($file);
    exit;
}

?>
