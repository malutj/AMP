/* * * * * * * * * * * * * * 
 * Jason M Malutich
 * 1 August, 2014
 * Miller Public Relations
 * * * * * * * * * * * * * */

$(document).ready(function(){

	//Determine whether user is logged in
	checkLoginStatus();

	//If user is logged in, populate page
	populatePage()
	

});

function checkLoginStatus(){
	//Make GET request to check login status
	$.GET("php/login_status.php", function(result){
		if(result.login == "false"){
			window.location.replace("login.html");
		}
	}, "json");
}