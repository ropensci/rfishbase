taxendpt <- endpoint("taxa") 

#' Taxonomy
#' 
#' @export
#' @param genus (character) genus name. optional
#' @param species (character) species name. optional
#' @param limit The maximum number of matches from a single API call (e.g. 
#' per species). Function will warn if this needs to be increased, otherwise 
#' can be left as is. 
#' @param server base URL to the FishBase API (by default). For SeaLifeBase, 
#' use https://fishbase.ropensci.org/sealifebase
#' @param ... additional arguments to httr::GET
#' @examples 
#' taxonomy(genus = "Oreochromis", species = "amphimelas")
#' taxonomy(genus = "Oreochromis")
#' taxonomy(species = "amphimelas")
#' 
#' taxonomy(genus = "Abrocoma", 
#'   server = "https://fishbase.ropensci.org/sealifebase")
taxonomy <- function(genus = NULL, species = NULL, limit = 200, 
  server = getOption("FISHBASE_API", FISHBASE_API), ...) {
  
  taxendpt(query = list(Genus = genus, Species = species), limit = limit, 
           server = server, ...)
}


# taxonomy <- function(genus = NULL, species = NULL, limit = 200, 
#                      server = NULL, ...) {
#   
#   taxendpt(query = list(Genus = genus, Species = species), limit = limit, 
#            server = server, ...)
# }
