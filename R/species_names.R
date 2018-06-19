#' species names
#' 
#' returns species names given FishBase's SpecCodes
#' 
#' @param codes a vector of speccodes (e.g. column from a table)
#' @return A character vector of species names for the SpecCodes
#' @inheritParams species
#' @export  species_names
#' @aliases  species_names
species_names <- function(codes, server =  getOption("FISHBASE_API", FISHBASE_API)){
  
  fb_species(server=server) %>% filter(SpecCode %in% codes)
}


