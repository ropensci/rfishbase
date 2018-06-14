
## Allows us to define functions for each endpoint using closures
#' @importFrom dplyr left_join
endpoint <- function(endpt, tidy_table = default_tidy){
  
  function(species_list = NULL, fields = NULL, server = getOption("FISHBASE_API", FISHBASE_API), ...){
    full_data <- fb_tbl(endpt)
    
    ## fix SpecCode inconsistencies
    if("Speccode" %in% names(full_data)){ 
      full_data <- rename(full_data, SpecCode = Speccode)
    }
    
    ## Subset by species list. Include species names
    out <- speccodes(species_list) %>% 
      dplyr::left_join(fb_species(), by="SpecCode") %>%
      dplyr::left_join(full_data, by="SpecCode")
    
    if(!is.null(fields)){
      out <- out[fields]
    }
    
    out
  }
}

