taxendpt <- endpoint("taxa") 

#' Taxonomy
#' 
#' @export
#' @param genus,species (character) genus or species (aka epithet) name. 
#' pass in either one or both
#' @param limit The maximum number of matches from a single API call (e.g. 
#' per species). Function will warn if this needs to be increased, otherwise 
#' can be left as is. 
#' @param server base URL to the FishBase API (by default). For SeaLifeBase, 
#' use https://fishbase.ropensci.org/sealifebase
#' @param ... additional arguments to \code{\link[httr]{GET}}
#' @examples 
#' taxonomy(genus = "Oreochromis", species = "amphimelas")
#' taxonomy(genus = "Oreochromis")
#' taxonomy(species = "amphimelas")
#' 
#' taxonomy(genus = "Abrocoma", 
#'   server = "https://fishbase.ropensci.org/sealifebase")
#'   
taxonomy <- function(genus = NULL, species = NULL, ...){ 
  species_list(Genus = genus, 
               Species = species)
}
