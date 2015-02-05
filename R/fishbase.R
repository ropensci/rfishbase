SERVER = "http://server.carlboettiger.info:4567"

## Provide wrapper to work with species lists.
#' @param species_list Takes a vector of scientific names (each element as "genus species").
#'   if only one name is given in an element (no space), assumes it is the genus and returns
#'   all species matching that genus.
#' @param verbose should the function give warnings?
#' @return a data.frame with rows for species and columns for the fields returned by the query (FishBase 'species' table)
#' @examples
#' \donttest{
#' 
#' species_table(c("Oreochromis niloticus", "Bolbometopon muricatum")) 
#' # There are 5 species in this genus, so returns 5 rows:
#' species_table("Labroides") 
#' }
#' @export
species_table <- function(species_list, verbose = TRUE, .limit = 50, .server = SERVER){
  # Just wraps an lapply around the "per_species" function and combines the resulting data.frames.
  # .limit limits the number of returns in a single API call.  As we are usually matching species, we expect
  # only one hit per call anyway so limit may as well be 1.  If we are matching genus only, we can hit
  # several species and limit should justifiably be higher. 
  do.call("rbind", lapply(species_list, per_species, verbose = verbose, limit = .limit, server = .server))
}



#' @import httr stringr
per_species <- function(species, verbose = TRUE, limit = 10, server = SERVER){
  
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




## Family query is 2 api calls, one to look up FamCode. 1 call for subFamily
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


## Metadata used by tidy_species_table
#meta <- system.file("metadata", "species.csv", package="rfishbase")
meta <- 'inst/metadata/species.csv'
species_meta <- read.csv(meta)
row.names(species_meta) <- species_meta$field


#' @import tidyr
tidy_species_table <- function(data) {
  L <- lapply(data, null_to_NA)
  df <- do.call(rbind.data.frame, L)
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


#' 
#' @import httr
get_id <- function(genus, species, server = SERVER){  
  resp <- GET(paste0(server, "/species", "/?genus=", genus, "&species=", species, "&fields=speciesrefno,speccode"))
  sapply(content(resp)$data, `[[`, "speciesrefno")
}



