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
        load_client_list();
      }
    },
    "json");

  //handles the logout button
  $("#logout_button").click(function(e){
    e.preventDefault();
    $.post("./php/validate.php", 
          {request_type : 'logout'}, 
          function(result){
            window.location = "login.html";
    });
  });

  //handles the add button
    $("#add_button").click(function(e){
      e.preventDefault();
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
function load_client_list(){
   $.get("./php/clients.php",
    {request_type : 'load'},
    function(result){
      if(result.status==='success'){
        client_list = result.client_list;
        populate_client_list();
      }
    }, 'json');
}
function populate_client_list(){
  s = "";
  $.each(client_list, function(index, val){
    s = s+"<div class='client'>";
    s = s+val.name+"<br>"+val.code;
    s = s+"</div>";
  });
  $("#client_list").html(s);
}



