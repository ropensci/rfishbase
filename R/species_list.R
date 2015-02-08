#' species_list
#' 
#' Get a list of scientific names for all species in the given taxonomic group
#' @details The first time the function is called it will download and cache the complete
#' @import dplyr lazyeval
#' @examples
#' \donttest{
#' ## All species in the Family Scaridae
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
  
  ## Just a few dplyr & dlpyr wrappers
  df <- taxa(query, all_taxa = all_taxa)
  df <- select_(df, "Genus", "Species")
  df <- unite_(df, "sci_name", c("Genus", "Species"), sep = " ") 
  df[[1]]
}

# Returns SpecCodes given a list of species, e.g. from sci_names. 
# Primarily for internal use
#
# @examples
# who <- species_list(Family='Scaridae')
# speccodes_for_species(who)
speccodes_for_species <- function(species_list){ 
  sapply(species_list, 
         function(x){ 
          s <- parse_name(x)
          speccode( list(Species=s$species, Genus=s$genus))
        })
}

# Helper routine for speccodes. 
speccode <- function(query, all_taxa = load_taxa()){
  df <- taxa(query, all_taxa = all_taxa)
  select_(df, "SpecCode")[[1]] 
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
  
  taxa <- filter_(all_taxa, 
                  .dots = dots) 
}


## Create an environment to cache the full speices table
rfishbase <- new.env(hash = TRUE)

# Contruct and cache the the taxa table from the server
load_taxa <- function(server = SERVER, verbose = TRUE, cache = TRUE){
  all_taxa <- mget('all_taxa', 
                   envir = rfishbase, 
                   ifnotfound = list(NULL))$all_taxa
  if(is.null(all_taxa))
    all_taxa <- complete_taxa_table(server = server, verbose = verbose, cache = cache)
  all_taxa
}

# Download the complete taxa table from the API. 
# A row for each species name, column for each taxonomic level or identifier
# Converts into about 12.5 MB data.frame
# By default, caches this table in a local environment for later use.
complete_taxa_table <- function(server = SERVER, verbose = TRUE, cache = TRUE){
  
  resp <- GET(paste0(server, "/taxa"), query = list(family='', limit=35000))
  all_taxa <- check_and_parse(resp, verbose = verbose)
  if(cache) assign("all_taxa", all_taxa, envir=rfishbase)
  all_taxa
}

