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
#' @importFrom httr GET user_agent 
#' @importFrom dplyr bind_rows
#' @export
#' @examples
#' \dontrun{
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
synonyms <- function(species_list, limit = 50, server = getOption("FISHBASE_API", FISHBASE_API), 
                     fields = c("SynGenus", "SynSpecies", "Valid", "Misspelling", 
                                "Status", "Synonymy", "Combination", "SpecCode",
                                "SynCode", "CoL_ID", "TSN", "WoRMS_ID")){
  
  
  dplyr::bind_rows(lapply(species_list, function(species){
    s <- parse_name(species)
    resp <- httr::GET(paste0(server, "/synonyms"), 
                query = list(SynSpecies = s$species, 
                             SynGenus = s$genus, 
                             SpecCode = s$speccode,
                             limit = limit,
                             fields = paste(fields, collapse=",")),
                user_agent(make_ua()))
    df <- check_and_parse(resp)
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



#' validate_names
#' 
#' Check for alternate versions of a scientific name and return the names FishBase recognizes as valid
#' @inheritParams species
#' @return a string of the validated names
#' @export
validate_names <- function(species_list, limit = 50, server = getOption("FISHBASE_API", FISHBASE_API)){
  out <- sapply(species_list, function(x) {
    syn_table <- synonyms(x, limit = limit, server = server)
    if(length(unique(syn_table$SpecCode)) > 1){
      warning(paste0("FishBase says that '", x, 
                    "' can also be misapplied to other species
                    but is returning only the best match.  
                    See synonyms('", x, "') for details"), call. = FALSE)
      syn_table <- dplyr::filter_(syn_table, .dots = list(~Synonymy != "misapplied name"))
    }
    ## FIXME consider dplyr::distinct instead of `unique` here.
    code <- unique(syn_table$SpecCode)
  
    if(is.null(code))
      warning(paste0("No match found for species '", x, "'"), call. = FALSE)

    ## Return the name listed as valid. 
    ## Nope; doesn't work.  eg.  because the valid name for "Auxis rochei" is "Auxis rochei rochei",
    ## but a syn_table doesn't return any valid name, only the spec code.   
    # syn_table <- synonyms(code, limit = limit, server = server)
    # who <- syn_table$Valid
    # c(syn_table$SynGenus[who], syn_table$SynSpecies[who])
    
    ## Faster and more accurate to just return the name associated with the speccode:
    species_names(code)
    
    })
  ## sapply will still return nested lists if a value is missing
  unname(unlist(out))
}

