<?php
//Turn on error reporting
ini_set('display_errors', 'On');

//include the database connection info
include('db_connect.php');
include('global.php');

//verify that request came from app
if(empty($_POST['app_code']) || $_POST['app_code'] != $app_code){
    echo("Sorry, we don't recognize the origination of this request.");
    exit;
}

//create PDO object
try{
    $pdo = new PDO($dbinfo, $dbuser, $dbpass);
}
catch (PDOException $e){
    echo("Error [".$e->getMessage()."]");
    exit;
}

//fetch list of paths for all common files
$common_file_list = get_file_list($common_dir);
echo var_dump($common_file_list);
echo "\n";
exit;
//fetch list of paths for all client-specific files
$client_dir = get_client_directory();
$unique_file_list = get_file_list();

//overwrite common files with client-specific files where required
$merged_list = merge_file_lists($common_file_list, $unique_file_list);

echo var_dump($merged_list);

//get file mod dates
$result = get_file_dates($merged_list);

$response['status'] = 'success';
$response['file_list'] = $result;
echo json_encode($response);
exit;

function get_file_list($dir){
    //get list of all files/directories inside main directory
    $f = array_values(array_diff(scandir($dir), array('..', '.')));
 
    //iterate through file array and dig out each directory
    for($i = 0; $i < count($f); $i++){
        $entry = $f[$i];
        $path = $dir.'/'.$entry;

        //entry is a directory
        if(is_dir($path)){
            //grab all files in directory
            $temp = array_values(array_diff(scandir($path), array('..', '.')));
            //append directory name to each entry
            foreach($temp as &$t){$t = $entry.'/'.$t;}
            //remove the entry from the file array
            unset($f[$i]);
            //decrement i
            $i--;
            //re-order the array
            array_values($f);
            //add temp array to file array
            array_merge($f, $temp);
            echo var_dump($f);
            exit;
        }
    }
    echo var_dump($f);
    exit;
    return $f;
}

function get_client_directory(){
    try{
        $query = 'SELECT name FROM clients WHERE clients.code = :client_code';
        $stmt = $pdo->prepare($query);
        $stmt->bindParam(':client_code', strip_tags($_POST['code']));
        if($stmt->execute()){
            $row = $stmt.fetch();
            return $main_dir.'/'.str_replace(" ", "_", $row['name']).'_'.$code;
        }
    }
    catch(PDOException $e){
        echo("Error [".$e->getMessage()."]");
        exit;
    }
}

function merge_file_lists($c, $u){
    //create all three file lists
    $common_files = array_diff($c, $u);             //files that are only in common folder
    $unique_files = array_diff($u, $c);             //files that are only in client folder
    $duplicate_files = array_intersect($u, $c);     //common files we're going to replace
    
    //merge unique/duplicate and prepend the client's directory
    $result = array_merge($unique_files, $duplicate_files);
    foreach($result as &$f){$f=$client_dir.'/'.$f;}
    
    //prepend common directory and add files to result array
    foreach($common_files as &$f){$f=$common_dir.'/'.$f;}
    $result = array_merge($result, $common_files);
    
    return $result;
}

function get_file_dates($f){
    $result = array();
    foreach($f as $e){
        array_push($result, array($e, filemtime($e)));
    }
    return $result;
}
?>