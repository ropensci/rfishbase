## Consider information from: Countries | FAO areas | Ecosystems | Occurrences | Point map | Introductions | Faunaf

#' locations
#' 
#' return a table of species locations as reported in FishBASE.org FAO location data
#' 
#' @inheritParams species_info
#' @import dplyr
#' @export
#' @examples
#' locations(species_list(Genus='Labroides'))
#' @details currently this is ~ FAO areas table (minus "note" field)
#' e.g. http://www.fishbase.us/Country/FaoAreaList.php?ID=5537
locations <- function(species_list, server = SERVER, limit = 100){
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
  resp <- GET(paste0(server, "/faoarref/", area_code), 
              query = list(limit = limit,
                           fields='AreaCode,FAO'))
  data <- check_and_parse(resp)
}



## FIXME: Reproduce the ECOSYSTEMS table: 
# see `ecosystems` sql-table
# http://www.fishbase.us/trophiceco/EcosysList.php?ID=5537