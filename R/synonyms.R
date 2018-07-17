#' synonyms
#' 
#' Check for alternate versions of a scientific name
#' @inheritParams species
#' @return A table with information about the synonym. Will generally be only a single
#' row if a species name is given.  If a FishBase SpecCode is given, all synonyms matching
#' that SpecCode are shown, and the table indicates which one is Valid for FishBase. This may
#' or may not match the valid name for Catalog of Life (Col), also shown in the table. See examples for details.
#' @details 
#' For further information on fields returned, see:
#' http://www.fishbase.org/manual/english/fishbasethe_synonyms_table.htm
#' @export
#' @examples
#' \donttest{
#' # Query using a synonym:
#' synonyms("Callyodon muricatus")
#'  
#'  # Check for misspellings or alternate names
#'  synonyms("Labroides dimidatus") # Species name misspelled
#' 
#'  # See all synonyms 
#'  species("Bolbometopon muricatum")
#'  }
synonyms <- function(species_list, server = getOption("FISHBASE_API", FISHBASE_API), 
                     ...){
  
  syn <- 
    fb_tbl("synonyms") %>%
    mutate(synonym = paste(SynGenus, SynSpecies)) %>% 
    select(synonym, Status, SpecCode, SynCode, 
           CoL_ID, TSN, WoRMS_ID, ZooBank_ID,
           TaxonLevel)
  
  if(is.null(species_list))
    return(syn)
  
  dplyr::left_join(
            data.frame(synonym = species_list, stringsAsFactors = FALSE),
            syn,by="synonym") %>% 
    left_join(fb_species(server=server), by = "SpecCode")
}


globalVariables(c("Status", "SpecCode", "SynCode", 
"CoL_ID", "TSN", "WoRMS_ID", "ZooBank_ID",
"TaxonLevel", "synonym", "SynGenus", "SynSpecies", "columns"))

#' validate_names
#' 
#' Check for alternate versions of a scientific name and return 
#' the scientific names FishBase recognizes as valid
#' @inheritParams species
#' @return a string of the validated names
#' @export
#' @importFrom dplyr filter pull
#' @examples \donttest{
#' validate_names("Abramites ternetzi")
#' }
validate_names <- function(species_list, server = getOption("FISHBASE_API", FISHBASE_API),...){
  
  synonyms(species_list, server = server) %>% 
    dplyr::filter(Status == "accepted name" || Status == "synonym") %>% 
    dplyr::pull(Species)
                       
    
}

