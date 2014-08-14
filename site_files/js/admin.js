$(document).ready(function(){
//----------ACTIONS----------//
  //Checks whether the user is logged in or not on load
  $.post("./php/validate.php",
    {request_type : 'validate'},
    function(result){
      if(result.status==="not logged in"){
        window.location = "login.html";
      }
      else{
        //populate_client_list();
      }
    },
    "json");

  //handles the logout button
  $("#logout_button").click(function(){
    $.post("./php/validate.php", 
          {request_type : 'logout'}, 
          function(result){
            window.location = "login.html";
    });
  });

  //handles the add button
    $("#add_button").click(function(){
        $.post("./php/clients.php",
          {request_type : 'add',
           client_name : $("#client_name").val()
          },
          function(result){
            if(result.status==="success"){
              //add client to global array and reprint todo list
            }
            else{
              //handle failure message
            }

        }, "json");
  });
});



