#' synonyms
#' 
#' Check for alternate versions of a scientific name
#' @inheritParams species_info
#' @return A table with information about the synonym. Will generally be only a single
#' row if a species name is given.  If a FishBase SpecCode is given, all synonyms matching
#' that SpecCode are shown, and the table indicates which one is Valid for FishBase. This may
#' or may not match the valid name for Catalog of Life (Col), also shown in the table. See examples for details.
#' @details 
#' For further information on fields returned, see:
#' http://www.fishbase.org/manual/english/fishbasethe_synonyms_table.htm
#' @examples
#' \donttest{
#' # Query using a synonym:
#' synonyms("Callyodon muricatus")
#'  
#'  # Check for misspellings or alternate names
#'  x <- synonyms("Labroides dimidatus") # Species name misspelled
#'  species_list(SpecCode = x$SpecCode)  # correct: "Labroides dimidiatus"
#' 
#'  # See all synonyms using the SpecCode
#'  species_info("Bolbometopon muricatum", fields="SpecCode")[[1]]
#'  synonyms(5537)
#'  }
#'  @import httr
#'  @export
synonyms <- function(species_list, verbose = TRUE, limit = 50, server = SERVER, 
                     fields = c("SynGenus", "SynSpecies", "Valid", "Misspelling", 
                                "ColStatus", "Synonymy", "Combination", "SpecCode",
                                "SynCode", "CoL_ID", "TSN", "WoRMS_ID")){
  
  
  bind_rows(lapply(species_list, function(species){
    s <- parse_name(species)
    resp <- GET(paste0(server, "/synonyms"), 
                query = list(SynSpecies = s$species, 
                             SynGenus = s$genus, 
                             SpecCode = s$speccode,
                             limit = limit,
                             fields = paste(fields, collapse=",")))
    df <- check_and_parse(resp, verbose = verbose)
    df <- reclass(df, "Valid", "logical")
    df <- reclass(df, "Misspelling", "logical")
    df
  }))
  
}



reclass <- function(df, col_name, new_class){
  if(col_name %in% names(df))
    df[[col_name]] <- as(df[[col_name]], new_class)
  df
}


