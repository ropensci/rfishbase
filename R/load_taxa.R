

FISHBASE_API <- "https://fishbase.ropensci.org"
SEALIFEBASE_API <- "https://fishbase.ropensci.org/sealifebase"

#' load_taxa
#' 
#' Load or update the taxa list
#' @param update logical, should we query the API to update the available list? 
#' @param cache should we cache the updated version throughout this session? 
#' (default TRUE, leave as is)
#' @inheritParams species
#' @return the taxa list
#' @export
load_taxa <- function(update = FALSE, cache = TRUE, server = getOption("FISHBASE_API", FISHBASE_API), limit = 5000L){
  
  ## Load the correct taxa table based on the server setting
  if(grepl("https*://fishbase.ropensci.org$", server)){
    cache_name <- "fishbase"
  } else if(grepl("https*://fishbase.ropensci.org/sealifebase", server)){
    cache_name <- "sealifebase"
  } else {
    warning("Did not recognize API, assuming it is fishbase")
    cache_name <- "fishbase"
    
  }
  
  
    if(update){
      
      #limit the limit to avoid uneccesary (empty) calls
      limit <- ifelse(server == getOption("FISHBASE_API", FISHBASE_API),  
                      min(limit,35000L),
                      min(limit,120000L))
      
      if(limit>5000){
        k <- 0
        all_taxa <- {}
        while(k<limit){
          
          resp <- GET(paste0(server, "/taxa"), 
                      query = list(limit=as.integer(min(5000,limit-k)), 
                                   offset=as.integer(k+1)), 
                      user_agent(make_ua()))
          k <- k+5000
          all_taxa_tmp <- check_and_parse(resp)
          drop <- match(c("Author", "Remark"), names(all_taxa_tmp)) ## Non-ascii fields, not needed
          all_taxa <- rbind(all_taxa,all_taxa_tmp[-drop])
        }
      } else {
      
      resp <- GET(paste0(server, "/taxa"), 
                  query = list(family='', limit=as.integer(limit)), 
                  user_agent(make_ua()))
      all_taxa <- check_and_parse(resp)
      drop <- match(c("Author", "Remark"), names(all_taxa)) ## Non-ascii fields, not needed
      all_taxa <- all_taxa[-drop]
      
      }
      
    } else {
      data(list = cache_name, package="rfishbase", envir = environment())
      all_taxa <- mget(cache_name, envir = environment())[[1]]
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
# fishbase <- load_taxa(update = TRUE, limit = 35000)
# sealifebase <- load_taxa(update=TRUE, server = "https://fishbase.ropensci.org/sealifebase", limit = 120000)
# save("fishbase", file = "data/fishbase.rda", compress = "xz")
# save("sealifebase", file = "data/sealifebase.rda", compress = "xz")
