$(document).ready(function(){
//----------ACTIONS----------//

  //Checks whether the user is logged in or not on load
  $.post("./php/validate.php",
    {requestType : 'validate'},
    function(result){
      if(result.status==="not logged in"){
        window.location = "login.html";
      }
      else{
        populate_client_list();
      }
    },
    "json");

  //handles the logout button
  $("#logout_button").click(function(){
  $.post("./php/validate.php", 
        {requestType : 'logout'}, 
        function(result){
          window.location = "login.html";
        });
  });

  //handles the add button
  $("#add_button").click(function(){
    $.post("./php/clients.php",
      {requestType : 'add',client_name : $("#client_name").val()},
      function(data){
        if(data.status==="success"){
          populate_todo_list();
        }
        else if(data.status==="fail"){
          //handle failure message
        }
        else{
          //not sure what message we got back
        }

      }, "json");
  });

  //handles the delete button
  $("#todo_list").on("click", ".control_panel", function(){
    var todo_id = $(this).parent().attr('id');
    $.post("./php/data.php",
      {requestType : 'delete', todo_id : todo_id},
      function(result){
        if(result.status==="success"){
          populate_todo_list();
        }
        else{
          $("#todo_list").html("There seems to have been an error");
        }
      }, "json");
  });

 //----------USER-DEFINED FUNCTIONS----------//

  function populate_todo_list(){
    $.post("./php/data.php", 
      {requestType : 'load'}, 
        function(result){
          if(result.status==="success"){
            if(result.data.length > 0){
              var new_html="<ul>";
                $.each(result.data, function(key, entry){
                  var next_todo = "<li><div class='todo' id ='"+
                      entry.todo_id+"'><div class='control_panel'>DELETE</div><div class='todo_content'>"+
                      entry.todo_text+"</div></div></li>";

                  new_html = new_html + next_todo;
                });
                new_html= new_html +"</ul>";
                $("#todo_list").html(new_html);
                $("#todo_list").append("<div style='text-align:left; margin-left:45px; margin-bottom: -15px; color: #1BC9F2;'>Click on a to-do item to delete</div>");
            }
            //no to-dos were found
            else{
              $("#todo_list").html("");
            }
          }
          else{
            $("#todo_list").html("Sorry, we were unable to load your to-do list");
          }
        },'json');
  }
});
