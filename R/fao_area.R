
## FIXME still writing these functions

locations <- function(species_list, server = SERVER, verbose = TRUE, limit = 100){
  codes <- speccodes_for_species(species_list)
  do.call("rbind", lapply(codes, faoareas))
}



faoareas <- function(code, server = SERVER, verbose = TRUE, limit = 100){
  resp <- GET(paste0(server, "/faoareas"), query = list(SpecCode = code, limit = limit))  
  data <- check_and_parse(resp, verbose = verbose)
  
  ## Look up area codes
  do.call("rbind", lapply(data$AreaCode, faoarrefs))
  
  ## cbind
  
  
}

faoarrefs <- function(area_code, server = SERVER, verbose = TRUE, limit = 100){
  ## add in a fields list to filter returned values
  resp <- GET(paste0(server, "/faoarrefs/", area_code), query = list(limit = limit))
  data <- check_and_parse(resp)
}