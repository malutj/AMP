/* * * * * * * * * * * * * * 
 * Jason M Malutich
 * 1 August, 2014
 * Miller Public Relations
 * * * * * * * * * * * * * */

$(document).ready(function(){

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