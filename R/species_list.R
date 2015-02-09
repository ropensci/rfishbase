#' species_list
#' 
#' Return the a species list given a taxonomic group
#' @param Class Request all species in this taxonomic Class
#' @param Order Request all species in this taxonomic Order
#' @param Family Request all species in this taxonomic Family
#' @param SubFamily Request all species in this taxonomic SubFamily
#' @param Genus Request all species in this taxonomic Genus
#' @param Species Request all species in this taxonomic Species
#' @param SpecCode Request species name of species matching this SpecCode
#' @param SpeciesRefNo Request species name of all species matching this SpeciesRefNo
#' @param all_taxa The data.frame of all taxa used for the lookup. By default will be loaded
#'  from cache if available, otherwise must be downloaded from the server; about 13 MB, may be 
#'  slow.
#' 
#' @details The first time the function is called it will download and cache the complete
#' @import dplyr lazyeval
#' @examples
#' \donttest{
#' ## All species in the Family 
#'   species_list(Family = 'Scaridae')
#' ## All species in the Genus 
#'   species_list(Genus = 'Labroides')
#' }
#' @export
species_list <- function(Class = NULL,
                         Order = NULL,
                         Family = NULL,
                         SubFamily = NULL,
                         Genus = NULL,
                         Species = NULL,
                         SpecCode = NULL,
                         SpeciesRefNo = NULL,
                         all_taxa = load_taxa()){
  
  query <- list(Class = Class, Order = Order,
                Family = Family, SubFamily = SubFamily,
                Genus = Genus, Species = Species,
                SpecCode = SpecCode, SpeciesRefNo = SpeciesRefNo)
  query <- query[!sapply(query, is.null)]
  ## Just a few dplyr & dlpyr wrappers
  df <- taxa(query, all_taxa = all_taxa)
  df <- select_(df, "Genus", "Species")
  df <- unite_(df, "sci_name", c("Genus", "Species"), sep = " ") 
  df[[1]]
}



# Returns SpecCodes given a list of species. Primarily for internal use
#
# @examples
# who <- species_list(Family='Scaridae')
# speccodes(who)
speccodes <- function(species_list, all_taxa = load_taxa()){ 
  ## Attempts to be clever.  Be sure to load_taxa() 
  # If cache doesn't exist, just query instead.
  
  all_taxa <- mget('all_taxa', envir = rfishbase, ifnotfound = list(NULL))$all_taxa
  if(is.null(all_taxa)){
    species_info(species_list, fields="SpecCode")$SpecCode
  } else {
    sapply(species_list, function(x){ 
      s <- parse_name(x)
      df <- taxa(list(Species=s$species, Genus=s$genus), all_taxa = all_taxa)
      select_(df, "SpecCode")[[1]] 
    })
  }
}


# Fast queries of the constructed taxa table using local caching and dplyr
taxa <- function(query, all_taxa = load_taxa()){  
  # Do some dplyr without NSE.  aka:
  # all_taxa %>% filter(Family == 'Scaridae') 
  dots <- lapply(names(query), function(level){
    value <- query[[level]]
    interp(~y == x, 
                .values = list(y = as.name(level), x = value))
  })
  
  filter_(all_taxa, 
          .dots = dots) 
}


## Create an environment to cache the full speices table
rfishbase <- new.env(hash = TRUE)


## FIXME consider exporting this.  
# Contruct and cache the the taxa table from the server
load_taxa <- function(server = SERVER, verbose = TRUE, cache = TRUE){
  
  all_taxa <- mget('all_taxa', 
                   envir = rfishbase, 
                   ifnotfound = list(NULL))$all_taxa
  
  if(is.null(all_taxa)){
    resp <- GET(paste0(server, "/taxa"), query = list(family='', limit=35000))
    all_taxa <- check_and_parse(resp, verbose = verbose)
    
    if(cache) 
      assign("all_taxa", all_taxa, envir=rfishbase)  
  }
  
  all_taxa
}
