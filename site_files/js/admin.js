$(document).ready(function(){
//global client list array
    client_list = [];
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
    var client_name = $("#client_name").val();
    e.preventDefault();
    $.post("./php/clients.php",
      {request_type : 'add',
       client_name : client_name
      },
      function(result){
        if(result.status==="success")
        {
          $("#client_name").val("");
          client_list.push({"cid":result.cid, "client_name": client_name, "client_code":result.code});
          populate_client_list();
        }
        else
        {
          $("#add_status").html(result.msg);
        }

    }, "json");
  });
    
//sync button for testing
    $("#sync_button").click(function(e){
       e.preventDefault();
       $.post("./php/sync.php",
              {app_code: "j5K4F98j3vnME57G10f",
               code: "7e45ff"
              },
             function(result){
                 if(result.status === 'success'){
                    
                 }
                 else{
                     alert("fail");
                 }
             },'json'
       );
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
  var s = "";
  $.each(client_list, function(index, val){
    s = s+"<div class='client"+(index%2)+"' id='"+val.cid+"'>";
    s = s+val.client_name+"<br>"+val.client_code;
    s = s+"</div>";
  });
  $("#client_list").html(s);
}



