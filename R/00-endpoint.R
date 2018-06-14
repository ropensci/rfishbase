
## Allows us to define functions for each endpoint using closures
#' @importFrom dplyr left_join
endpoint <- function(endpt, tidy_table = default_tidy){
  
  function(species_list = NULL, fields = NULL, server = getOption("FISHBASE_API", FISHBASE_API), ...){
    
    out <- dplyr::left_join(speccodes(species_list), fb_tbl(endpt))
    if(!is.null(fields)) out <- out[fields]
    
    out
  }
}

