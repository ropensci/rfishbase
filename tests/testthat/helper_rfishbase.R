
# Tests that contain this function will not be run if any of these conditions fail:
needs_api <- function(){
  
  skip_if_offline()
  skip_on_cran()  

}
