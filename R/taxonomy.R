

## SHOULD DEPRECATE THIS

#' Taxonomy
#' 
#' @export
#' @param genus,species (character) genus or species name. 
#' pass in either one or both
#' per species). Function will warn if this needs to be increased, otherwise 
#' can be left as is. 
#' @inheritParams species
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
