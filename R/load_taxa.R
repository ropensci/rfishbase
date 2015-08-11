

## Create an environment to cache the full speices table
rfishbase <- new.env(hash = TRUE)


FISHBASE_API <- "http://fishbase.ropensci.org"
SEALIFEBASE_API <- "http://fishbase.ropensci.org/sealifebase"

#' load_taxa
#' 
#' Load or update the taxa list
#' @param update logical, should we query the API to update the available list? 
#' @param cache should we cache the updated version throughout this session? 
#' (default TRUE, leave as is)
#' @inheritParams species
#' @return the taxa list
#' @export
load_taxa <- function(update = FALSE, cache = TRUE, server = getOption("FISHBASE_API", FISHBASE_API), limit = 400000L){
  
  ## Load the correct taxa table based on the server setting
  if(server == FISHBASE_API){
    cache_name <- "fishbase"
  } else if(server == SEALIFEBASE_API){
    cache_name <- "sealifebase"
  } else {
    warning("Did not reconize API, assuming it is fishbase`")
    cache_name <- "fishbase"
    
  }
  
  # First, try to load from cache
  all_taxa <- mget(cache_name, 
                   envir = rfishbase, 
                   ifnotfound = list(NULL))$all_taxa
  
  if(is.null(all_taxa)){
    
    if(update){
      
      resp <- GET(paste0(server, "/taxa"), 
                  query = list(family='', limit=as.integer(limit)), 
                  user_agent(make_ua()))
      all_taxa <- check_and_parse(resp)
      drop <- match(c("Author", "Remark"), names(all_taxa)) ## Non-ascii fields, not needed
      all_taxa <- all_taxa[-drop]
      
      if(cache){ 
        assign(cache_name, all_taxa, envir=rfishbase)  
      }
    } else {
      
      data(list = cache_name, package="rfishbase", envir = environment())
      all_taxa <- mget(cache_name, envir = environment())[[1]]
    }
    
  }  
  all_taxa
}

#' A table of all the the species found in FishBase, including taxonomic
#' classification and the Species Code (SpecCode) by which the species is
#' identified in FishBase.
#'
#' @name fishbase
#' @docType data
#' @author Carl Boettiger \email{carl@@ropensci.org}
#' @references \url{FishBase.org}
#' @keywords data
NULL


#' A table of all the the species found in SeaLifeBase, including taxonomic
#' classification and the Species Code (SpecCode) by which the species is
#' identified in SeaLifeBase
#'
#' @name sealifebase
#' @docType data
#' @author Carl Boettiger \email{carl@@ropensci.org}
#' @references \url{www.sealifebase.org}
#' @keywords data
NULL


## Code to update the package cache:
# fishbase <- load_taxa(update = TRUE)
# save("fishbase", file = "data/fishbase.rda", compress = "xz")

