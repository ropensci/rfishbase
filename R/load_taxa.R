
## Create an environment to cache the full speices table
rfishbase <- new.env(hash = TRUE)


## FIXME consider exporting this.  
# Contruct and cache the the taxa table from the server
load_taxa <- function(server = SERVER, verbose = TRUE, cache = TRUE, update = FALSE){
  
  all_taxa <- mget('all_taxa', 
                   envir = rfishbase, 
                   ifnotfound = list(NULL))$all_taxa
  
  if(is.null(all_taxa)){
    
    if(update){
      resp <- GET(paste0(server, "/taxa"), query = list(family='', limit=35000))
      all_taxa <- check_and_parse(resp, verbose = verbose)
    } else {
      data("all_taxa", package="rfishbase", envir=environment())
    }
    if(cache) 
      assign("all_taxa", all_taxa, envir=rfishbase)  
  }
  
  all_taxa
}
