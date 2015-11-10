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
#' @importFrom dplyr select_ %>%
#' @importFrom lazyeval interp
#' @importFrom tidyr unite_
#' @examples
#' \dontrun{
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
  df <- dplyr::select_(df, "Genus", "Species")
  df <- tidyr::unite_(df, "sci_name", c("Genus", "Species"), sep = " ") 
  df[[1]]
}



# speccodes
#
# Returns SpecCodes given a list of species. Primarily for internal use
# 
# @examples
# who <- species_list(Family='Scaridae')
# speccodes(who)
speccodes <- function(species_list, all_taxa = load_taxa()){ 
    sapply(species_list, function(x){ 
      s <- parse_name(x)
      df <- taxa(list(Species=s$species, Genus=s$genus, SpecCode=s$speccode), all_taxa = all_taxa)
      dplyr::select_(df, "SpecCode")[[1]] 
    })
}


# Fast queries of the constructed taxa table using local caching and dplyr
taxa <- function(query, all_taxa = load_taxa()){  
  # Do some dplyr without NSE.  aka:
  # all_taxa %>% filter(Family == 'Scaridae') 
  
  query <- query[!sapply(query, is.null)]
  dots <- lapply(names(query), function(level){
    value <- query[[level]]
    lazyeval::interp(~y == x, 
                .values = list(y = as.name(level), x = value))
  })
  
  dplyr::filter_(all_taxa, 
          .dots = dots) 
}

