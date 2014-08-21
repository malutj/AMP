/* * * * * * * * * * * * * * 
 * Jason M Malutich
 * 1 August, 2014
 * Miller Public Relations
 * * * * * * * * * * * * * */

$(document).ready(function(){

	//check_login_status();

//----------ANIMATIONS----------//

    //Username text field
	$("#username")
      .focus(function(){
	    if($("#username").val()===" USERNAME"){
          $("#username")
            .val("")
            .css("color","black"); 
	    }
	  })
      .focusout(function(){
		if($("#username").val()===""){
	    	$("#username")
              .val(" USERNAME")
              .css("color","gray");
	    }
	});

    //Password text field
	$("#password")
      .focus(function(){
	    if($("#password").val()===" PASSWORD"){
	    	$("#password")
              .val("")
	    	  .prop("type","password")
              .css("color","black");
	    }
	  })
      .focusout(function(){
		if($("#password").val()===""){
	    	$("#password")
              .val(" PASSWORD")
	    	  .prop("type","text")
              .css("color","gray");
	    }
	});

//allow user to use enter key to submit
$("#username").keyup(function(event){
    if(event.keyCode == 13){
        $("#login_button").click();
    }
});
    
$("#password").keyup(function(event){
    if(event.keyCode == 13){
        $("#login_button").click();
    }
});

	
//Handles login button press
	$("#login_button").click(function(e){
        e.preventDefault();
		if(validate()){
			$.post("./php/validate.php",
        		{   request_type :  'login',
                    username    :  $("#username").val(),
                    password    :  $("#password").val()
                },
        		function(result){
        			if(result.status==="success"){
        				window.location = "admin.html";
        			}
        			else{
        			    $("#login_status").html(result.msg);
    	                setTimeout(function(){$("#login_status").html("");}, 3000);
        			}
        		},"json");
		}
	});
});

function validate(){
	var passed = true;
	if($("#username").val() === " USERNAME"){
		passed = false;
		$("#username_status").html("Please enter a username");
		setTimeout(function(){$("#username_status").html("");}, 3000);
	}
	if($("#password").val() === " PASSWORD"){
		passed = false;
		$("#password_status").html("Please enter a password");
		setTimeout(function(){$("#password_status").html("");}, 3000);
	}
	return passed;
}

function check_login_status(){
  //Checks whether the user is logged in or not
	$.post("./php/validate.php",
		{request_type : 'validate'},
		function(result){
			if(result.status==="logged in"){
				window.location = "admin.html";
			}
		},"json");
}
