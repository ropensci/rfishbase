SERVER = "http://server.carlboettiger.info:4567"


#' @import httr
#' @export
summary <- function(sci_name, server = SERVER, verbose = TRUE, limit = 10){
  resp <- GET(paste0(server, "/species", "/?genus=", genus,
                     "&species=", species, "&limit=", limit))

  ## check response for http errors
  stop_for_status(resp)
  
  ## Parse the http response
  out <- content(resp)
    
  ## Check for errors or other issues
  error_checks(out, verbose = verbose)
  
  ## Combine into data.frame and tidy
  tidy_species_table(out$data)
}


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


#' 
#' @import httr
get_id <- function(genus, species, server = SERVER){  
  resp <- GET(paste0(server, "/species", "/?genus=", genus, "&species=", species, "&fields=speciesrefno"))
  sapply(content(resp)$data, `[[`, "speciesrefno")
}
