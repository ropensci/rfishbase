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
#' # many names
#' spp <- list(c("Oreochromis", "amphimelas"), c("Oreochromis", "mweruensis"))
#' Map(function(x) taxonomy(x[1], x[2]), spp)
#' ## or if you already have genus+epithet together
#' spp <- c("Oreochromis amphimelas", "Oreochromis mweruensis")
#' spl <- function(x) strsplit(x, "\\s")[[1]]
#' Map(function(x) { z <- spl(x); taxonomy(z[1], z[2]) }, spp)
taxonomy <- function(genus = NULL, species = NULL, limit = 200, 
  server = getOption("FISHBASE_API", FISHBASE_API), ...) {
  
  if (is.null(Filter(Negate(is.null), c(genus, species)))) 
    stop("must pass in genus, species, or both")
  taxendpt(query = list(Genus = genus, Species = species), limit = limit, 
           server = server, ...)
}
