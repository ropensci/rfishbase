
## Allows us to define functions for each endpoint using closures
#' @importFrom dplyr left_join rename
endpoint <- function(endpt, tidy_table = default_tidy){
  
  function(species_list = NULL, fields = NULL, server = getOption("FISHBASE_API", FISHBASE_API), ...){
    full_data <- fb_tbl(endpt)
    
    full_data <- fix_ids(full_data)
    out <- species_subset(species_list, full_data)
    
    if(!is.null(fields)){
      out <- out[fields]
    }
    
    out
  }
}

species_subset <- function(species_list, full_data){
  if(is.null(species_list))
    return(full_data)
  
  suppressMessages({
    out <- speccodes(species_list) %>% 
      dplyr::left_join(fb_species(), by = "SpecCode") %>%
      dplyr::left_join(full_data)
  })
  out
}


fix_ids <- function(full_data){
  if("Speccode" %in% names(full_data)){ 
    full_data <- dplyr::rename(full_data, SpecCode = Speccode)
  }
  full_data
}
