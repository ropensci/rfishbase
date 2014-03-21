#' get the species table from Fishbase SQL
#' 
#' get the species table from Fishbase SQL
#' @param species the species name
#' @param as format desired for the return object, e.g. list, or xml object
#' @param ... additional arguments to httr::GET
#' @param debug logical, turn on debug mode to recieve the full response object
#' @return the requested output, or the httr response object if either debug=TRUE
#' or the server response type is something other than 200 (response okay).
#' @import httr
#' @import XML
fb2_species_table <- function(species, as = c("list", "xml"), ..., debug = FALSE){
  # FIXME Add a nice function to handle incorrect spellings of names, common names, etc


  as <- match.arg(as)

  base <- "http://www.deepspaceweb.com/fishbase/api"
  table <- "species"
  type = "xml"

  query <- paste(base, table, species, sep="/"), 
  query <- paste(query, "?type=", type, sep="")
  response <- GET(query, ...)
  if(debug | response$status != 200)
    response
  else {
    out <- xmlParse(content(response, "text"))
    if(as == "list")
      out <- xmlToList(out)
    out
  }
    

## wrap this with some helper function to parse the results into more useful things.  
