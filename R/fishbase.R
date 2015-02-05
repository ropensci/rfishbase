SERVER = "http://server.carlboettiger.info:4567"

# Use a separate function to query by higher taxonomy, including by genus

# FIXME: 
#  - what should this function be called?
#  - handle species lists?
#  - should you be able to filter?
#  
#' @import httr stringr
#' @export
summary <- function(species = NULL, server = SERVER, verbose = TRUE, limit = 10){
  
  ## parse scientific name (FIXME function should also do checks.)
  s <- parse_name(species)
  
  ## Make the API call for the species requested
  args <- list(species = s$species, genus = s$genus, limit = limit)
  resp <- GET(paste0(server, "/species"), query = args)
  
  ## check response for http errors
  stop_for_status(resp)
  
  ## Parse the http response
  out <- content(resp)
  
  ## Check for errors or other issues
  error_checks(out, verbose = verbose)
  
  ## Combine into data.frame and tidy
  tidy_species_table(out$data)
}

## FIXME provide wrapper to work with species lists.



## FIXME provide wrapper to work with genus, subFamily query (b.c. it's 1 API call).
## Family query is 2 api calls, one to look up FamCode.
## Higher taxonomy: less relevant?

error_checks <- function(resp, verbose = TRUE){
  ## check for errors in the API query
  if(!is.null(out$error) && verbose) 
    stop(out$error)
  
  ## Comment if returns are incomplete.
  if(verbose && out$count > out$returned)
    warning(paste("Retruning first", out$returned, "matches out of", out$count, "matches.",
                  "\n Increase limit or refine query for more results"))
  
}



tidy_species_table <- function(data) {
  L <- lapply(data, null_to_NA)
  df <- do.call(rbind.data.frame, L)
  # Convert columns to the appropriate class
  
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
  x <- str_split(species, " ")[[1]]
  list(genus = x[1], species = x[2])
}


#' 
#' @import httr
get_id <- function(genus, species, server = SERVER){  
  resp <- GET(paste0(server, "/species", "/?genus=", genus, "&species=", species, "&fields=speciesrefno,speccode"))
  sapply(content(resp)$data, `[[`, "speciesrefno")
}



