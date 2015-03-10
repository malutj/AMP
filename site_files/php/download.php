<?php
//Turn on error reporting
ini_set('display_errors', 'On');

//verify that request came from app
if(empty($_POST['app_code']) || $_POST['app_code'] != $app_code){
    echo("Sorry, we don't recognize the origination of this request.");
    die();
}

//get POST variables
$f = (empty($_POST['file'])) ? NULL : $_POST['file'];

//send the file
if ($f != null && file_exists($f)){
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
