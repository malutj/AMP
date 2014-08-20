<?php
	session_start();
?>

<!DOCTYPE html>
<html>
  <head>
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.0/jquery.min.js"></script>
    <script type="text/javascript" src="js/admin.js"></script>
    <link rel='stylesheet' href='style/admin.css'> 
  </head>
  <body>
    <header>
      <a href="http://www.ampupmypractice.com">
            <img alt="Animated Medical Procedures" src="http://www.ampupmypractice.com/wp-content/uploads/2012/09/amp-logo1.png"></img>
      </a>
    </header>
    <div class="content">
      <a class="tt-button green" href="" id="logout_button">Logout</a><br><br>
      <a class="tt-button green" href="" id="sync_button">Sync</a><br><br>
      <div class="box">
        <div class="boxheader">Add Client</div>
        <div class="boxcontent">
          <table>
            <tr>
              <td>Client Name</td>
              <td><input type="text" id="client_name"></td>
              <td></td>
            </tr>
            <tr>
              <td></td>
              <td><a class="tt-button green" href="" id="add_button">Add</a></td>
              <td id="add_status"></td>
            </tr>
          </table>
        </div>
      </div>
      <div class="box">
        <div class="boxheader">Client List</div>
        <div class="boxcontent" id="client_list">
        </div>
      </div>
    </div>
  </body>
</html>
