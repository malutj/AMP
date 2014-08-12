/* * * * * * * * * * * * * * 
 * Jason M Malutich
 * 1 August, 2014
 * Miller Public Relations
 * * * * * * * * * * * * * */

$(document).ready(function(){

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
	//Handles login button press
	$("#login_button").click(function(){
		if(validate()){
			//post data to login.php and handle response
		}
	});

});

function validate(){
	var passed = true;
	if($("#username").val() == ""){
		passed = false;
		/*
		
			change text box color

		*/
	}
	if($("#password").val() == ""){
		passed = false;
		/*
		
			change text box color

		*/
	}
	return passed;
}
