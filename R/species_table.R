SERVER = "http://server.carlboettiger.info:4567"

#' species_table
#' 
#' Provide wrapper to work with species lists.
#' @param species_list Takes a vector of scientific names (each element as "genus species").
#'   if only one name is given in an element (no space), assumes it is the genus and returns
#'   all species matching that genus.
#' @param verbose should the function give warnings?
#' @param limit The maximum number of matches from a single API call.  (Applicable only when
#'  querying at genus level, typically only one #' record will match the scientific name and
#'  will try all names given.)  Thus the default is almost always fine. 
#' @param server URL of the FishBase API server.
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
#' species_table(c("Oreochromis niloticus", "Bolbometopon muricatum")) 
#' # There are 5 species in this genus, so returns 5 rows:
#' species_table("Labroides") 
#' }
#' @import httr stringr tidyr
#' @export
species_table <- function(species_list, verbose = TRUE, limit = 50, server = SERVER, fields=NULL){
  # Just wraps an lapply around the "per_species" function and combines the resulting data.frames.
  # .limit limits the number of returns in a single API call.  As we are usually matching species, we expect
  # only one hit per call anyway so limit may as well be 1.  If we are matching genus only, we can hit
  # several species and limit should justifiably be higher. 
  do.call("rbind", lapply(species_list, per_species, verbose = verbose, limit = limit, server = server, fields=fields))
}



per_species <- function(species, verbose = TRUE, limit = 10, server = SERVER, fields=NULL){
  
  ## parse scientific name (FIXME function should also do checks.)
  s <- parse_name(species)
  
  ## Make the API call for the species requested
  args <- list(species = s$species, genus = s$genus, 
               limit = limit, fields = paste(fields, collapse=","))
  resp <- GET(paste0(server, "/species"), query = args)
  
  data <- check_and_parse(resp, verbose = verbose)
  
  if(is.null(fields))
    ## Combine into data.frame and tidy
    tidy_species_table(data)
  else
    ## if filtering by fields, skip tidy
    data

}


check_and_parse <- function(resp, verbose = TRUE){
  stop_for_status(resp)
  
  ## Parse the http response
  parsed <- content(resp)
  
  ## Check for errors or other issues
  proceed <- error_checks(parsed, verbose = verbose)
  
  if(proceed)
    ## Collapse to data.frame
    to_data.frame(parsed$data)
  else
    NULL
}

## Family query is 2 api calls, one to look up FamCode. 1 call for subFamily
## Higher taxonomy: less relevant?




error_checks <- function(parsed, verbose = TRUE){
  
  proceed <- TRUE
  
  ## check for errors in the API query
  if(!is.null(parsed$error)) {
    if(verbose) stop(parsed$error)
    proceed <- FALSE
  }
  
  ## Comment if returns are incomplete.
  if(parsed$count > parsed$returned){
    if(verbose) warning(paste("Retruning first", parsed$returned, 
                    "matches parsed of", parsed$count, "matches.",
                    "\n Increase limit or refine query"))
    proceed <- TRUE
  }
  
  if(parsed$count == 0){
    warning("No matches to query found")
    proceed <- FALSE
  }
  
  proceed
}


## Metadata used by tidy_species_table
meta <- system.file("metadata", "species.csv", package="rfishbase")
species_meta <- read.csv(meta)
row.names(species_meta) <- species_meta$field

to_data.frame <- function(data){
  L <- lapply(data, null_to_NA)
  do.call(rbind.data.frame, L)  
}

## helper routine for tidying species data
tidy_species_table <- function(df) {
  # Convert columns to the appropriate class
  for(n in names(df)){
    class <- as.character(species_meta[[n, "class"]])
    if(class=="Date")
      df[,n] <- as.Date(as.character(df[,n]))
    else if(class=="logical")
      df[,n] <- as(as.numeric(df[,n]), class)
    else 
      df[,n] <- as(as.character(df[,n]), class)
  }
  ## Drop useless columns. Once reference table implemented, we may want to return those numbers. Same for expert ids.
  df <- df[,species_meta$keep]
  ## Rename columns (pick names to indicate units on numeric values?)
  
  ## Arrange columns
  
  df
}

# simple helper function
null_to_NA <- function(x) {
  x[sapply(x, is.null)] <- NA
  return(x)
}

# resp <- GET("http://server.carlboettiger.info:4567/species/?genus=Labroides")
# data <- content(resp)$data
# tidy_species_table(data)

# -1 is TRUE, 0 is FALSE



# parse scientific name.   FIXME stupid function, should do more check & error handling
parse_name <- function(x){
  x <- str_split(x, " ")[[1]]
  switch(length(x), 
         list(genus = x[1]),
         list(genus = x[1], species = x[2]))
}



