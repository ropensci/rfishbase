#' locations
#' 
#' return a table of species locations as reported in FishBASE.org FAO location data
#' 
#' @inheritParams species_info
#' @import dplyr
#' @export
#' @examples
#' locations(species_list(Genus='Labroides'))
locations <- function(species_list, server = SERVER, verbose = TRUE, limit = 100){
  codes <- speccodes(species_list)
  bind_rows(lapply(codes, faoareas))
}



faoareas <- function(code, server = SERVER, limit = 100){
  resp <- GET(paste0(server, "/faoareas"), 
              query = list(SpecCode = code, limit = limit,
                           fields='AreaCode,SpecCode,Status'))  
  table1 <- check_and_parse(resp)
  
  ## Look up area codes
  table2 <- bind_rows(lapply(table1$AreaCode, faoarrefs))
  left_join(table1, table2,by='AreaCode')
  ## cbind
  
  
}

faoarrefs <- function(area_code, server = SERVER, limit = 100){
  ## add in a fields list to filter returned values
  resp <- GET(paste0(server, "/faoarrefs/", area_code), 
              query = list(limit = limit,
                           fields='AreaCode,FAO'))
  data <- check_and_parse(resp)
}

