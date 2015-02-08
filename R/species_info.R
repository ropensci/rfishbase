SERVER = "http://server.carlboettiger.info:4567"

#' species_info
#' 
#' Provide wrapper to work with species lists. 
#' @param species_list A vector of scientific names (each element as "genus species").
#' @param verbose logical. Should the function give warnings? (default TRUE)
#' @param limit The maximum number of matches from a single API call (e.g. per species).  When verbose=TRUE, function
#'   will warn if this needs to be increased, otherwise can be left as is. 
#' @param server base URL to the FishBase API, should leave as default.
#' @param fields a character vector specifying which fields (columns) should be returned. By default,
#'  all available columns recognized by the parser are returned. This option can be used to the amount
#'  of data transfered over the network if only certain columns are needed.  
#' @return a data.frame with rows for species and columns for the fields returned by the query (FishBase 'species' table)
#' @details 
#' The Species table is the heart of FishBase. This function provides a convenient way to 
#' query, tidy, and assemble data from that table given an entire list of species.
#' For details, see: http://www.fishbase.org/manual/english/fishbasethe_species_table.htm
#' 
#' Species scientific names are defined according to fishbase taxonomy and nomenclature.
#' 
#' @examples
#' \donttest{
#' 
#' species_info(c("Oreochromis niloticus", "Bolbometopon muricatum")) 
#' 
#' }
#' @import httr stringr tidyr dplyr
#' @export
species_info <- function(species_list, verbose = TRUE, limit = 50, server = SERVER, fields = NULL){ 
  bind_rows(lapply(species_list, function(species){
  
    ## parse scientific name (FIXME function should also do checks.)
    s <- parse_name(species)

    ## Make the API call for the species requested
    args <- list(species = s$species, genus = s$genus, 
                 limit = limit, fields = paste(fields, collapse=","))
    resp <- GET(paste0(server, "/species"), query = args)
    data <- check_and_parse(resp, verbose = verbose)
  
    
    tidy_species_table(data)  ## FIXME Tidy should work even if we are filtering
    
  })) 
}



## Metadata used by tidy_species_table
meta <- system.file("metadata", "species.csv", package="rfishbase")
species_meta <- read.csv(meta)
row.names(species_meta) <- species_meta$field


## helper routine for tidying species data
tidy_species_table <- function(df) {
  # Convert columns to the appropriate class
  for(n in names(df)){
    class <- as.character(species_meta[[n, "class"]])
    if(class=="Date"){
      df[[n]] <- as.Date(df[[n]])
    } else if(class=="logical"){
      df[[n]] <- as(as.numeric(as.character(df[[n]])), class)
    } else {
      df[[n]] <- as(as.character(df[[n]]), class) # Will warn when class=integer & value is NA
    }
  }
  ## Drop useless columns. 
  ## Once reference table implemented, we may want to return those numbers. Same for expert ids.
  keep <- species_meta$field[species_meta$keep]
  keep_id <- match(keep, names(df))
  keep_id <- keep_id[!is.na(keep_id)]
  df <- df[,keep_id]
  ## Rename columns (pick names to indicate units on numeric values?)
  
  ## Arrange columns
  
  df
}
