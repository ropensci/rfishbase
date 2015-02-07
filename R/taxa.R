#' sci_names
#' 
#' Get scientific names by taxonomic group
#' 
#' @import dplyr lazyeval
#' @examples
#' sci_names(list(Family = 'Scaridae'))
#' sci_names(list(Genus = 'Labroides'))
#' @export
#' FIXME consider altering query such that taxonomic levels are explicit arguments intead
sci_names <- function(query, all_taxa = load_taxa()){
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
# who <- sci_names(list(Family='Scaridae'))
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

#
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

