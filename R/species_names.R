#' species names
#' 
#' returns species names given FishBase's SpecCodes
#' 
#' @param codes a vector of speccodes (e.g. column from a table)
#' @return A character vector of species names for the SpecCodes
#' @inheritParams species
#' @export  species_names
#' @aliases  species_names
species_names <- function(codes, 
                          server = getOption("FISHBASE_API", "fishbase"), 
                          version = get_latest_release(),
                          db = default_db()){
  
  fb_species(server, version, db) %>% filter(SpecCode %in% codes) %>% collect()
}


