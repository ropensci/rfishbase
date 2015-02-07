## Function name suggests we are looking up common name, not giving it
# common_to_sci(c("Bicolor cleaner wrasse", "humphead parrotfish"))
common_to_sci <- function(x, Language = NULL, verbose = TRUE, limit = 10, server = SERVER){
  
  sapply(x, function(x){
    # Look up SpecCode for the common names
    resp <- GET(paste0(server, "/comnames"), 
                query = list(ComName = x,
                             Language = Language,
                             limit = limit,  # SpecCode same for all matches
                             fields = 'SpecCode'))
    data <- check_and_parse(resp, verbose = verbose)
    
    # Check if we have gotten different species codes for the same
    # FIXME this isn't ideal behavior. Do something more intelligent
    if(!all(data[[1]] == data[[1]][[1]]))
      warning("Common name matches multiple scientific names, using first match")
    
    ## Grab the first code
    code <- data[[1]][[1]]
    # Turn SpecCode into scientific name. Use local taxa table for speed
    sci_names(list(SpecCode=code))
  })
  
}




## Note that there are many common names for a given sci name, so sci_to_common doesn't make sense
## FIXME consider if there are additional fields we want to add here.
find_commonnames <- function(species_list, verbose = TRUE, limit = 100, server = SERVER){
  codes <- species_table(species_list, fields="SpecCode")$SpecCode
  
  do.call('rbind.data.frame', 
          lapply(codes, 
                function(code, verbose, limit){
                  
    resp <- GET(paste0(server, "/comnames"), 
                query = list(SpecCode = code, 
                             limit = limit, fields = 'SpecCode,ComName,Language'))
    check_and_parse(resp, verbose = verbose)
  }, 
  verbose = verbose, limit = limit))
}
# N <- find_commonnames(c("Labroides bicolor"))