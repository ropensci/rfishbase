
# Tests that contain this function will not be run if any of these conditions fail:
needs_api <- function(){

  skip_on_cran()  
#  skip("No response from internet, skipping test")
#  if(httr::status_code(heartbeat()) != 200) 
#    skip("No response from API, skipping test")
#  if(!httr::content(ping())$mysql_server_up) 
#    skip("No MySQL connection, skipping test")
}
