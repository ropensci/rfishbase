
## Allows us to define functions for each endpoint using closures
#' @importFrom dplyr left_join
endpoint <- function(endpt, tidy_table = default_tidy){
  
  function(species_list = NULL, server = getOption("FISHBASE_API", FISHBASE_API), ...){
    
    dplyr::left_join(speccodes(species_list), fb_tbl(endpt))
    
  }
}

