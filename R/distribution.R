## Consider information from: Countries | FAO areas | Ecosystems | Occurrences | Point map | Introductions | Faunaf

#' distribution
#' 
#' return a table of species locations as reported in FishBASE.org FAO location data
#' 
#' @inheritParams species_info
#' @import dplyr
#' @export
#' @examples \donttest{
#' distribution(species_list(Genus='Labroides'))
#' }
#' @details currently this is ~ FAO areas table (minus "note" field)
#' e.g. http://www.fishbase.us/Country/FaoAreaList.php?ID=5537
distribution <- function(species_list, server = SERVER, limit = 500){
  faoareas(species_list, server = server, limit = limit)
}


#' faoareas
#' 
#' return a table of species locations as reported in FishBASE.org FAO location data
#' 
#' @inheritParams species_info
#' @import dplyr
#' @export
#' @examples 
#' \donttest{
#'   faoareas(species_list(Genus='Labroides'))
#' }
#' @details currently this is ~ FAO areas table (minus "note" field)
#' e.g. http://www.fishbase.us/Country/FaoAreaList.php?ID=5537
faoareas <- function(species_list, server = SERVER, limit = 500){
  codes <- speccodes(species_list)
  out <- bind_rows(lapply(codes, function(code){
  
  resp <- GET(paste0(server, "/faoareas"), 
              query = list(SpecCode = code, limit = limit,
                           fields='AreaCode,SpecCode,Status'),
              user_agent(make_ua()))  
  table1 <- check_and_parse(resp)
  
  ## Look up area codes
  table2 <- bind_rows(lapply(table1$AreaCode, faoarrefs))
  left_join(table1, table2,by='AreaCode')
  ## cbind
  
  }))
  
  out
}


faoarrefs <- function(area_code, server = SERVER, limit = 100){
  ## add in a fields list to filter returned values
  resp <- GET(paste0(server, "/faoarref/", area_code), 
              query = list(limit = limit,
                           fields='AreaCode,FAO'),
              user_agent(make_ua()))
  data <- check_and_parse(resp)
}


## FIXME: Reproduce the ECOSYSTEMS table: 
# see `ecosystems` sql-table
# http://www.fishbase.us/trophiceco/EcosysList.php?ID=5537

#' ecosystems
#' 
#' @return a table of species ecosystems data
#' @inheritParams species_info
#' @export
#' @examples \donttest{
#' ecosystems("Oreochromis niloticus")
#' }
ecosystems <- endpoint("ecosystems")

#' occurrence
#' 
#' @return a table of species occurrence data
#' @inheritParams species_info
#' @export
#' @examples \donttest{
#' occurrence("Oreochromis niloticus")
#' }
occurrence <- endpoint("occurrence")

#' introductions
#' 
#' @return a table of species introductions data
#' @inheritParams species_info
#' @export
#' @examples \donttest{
#' introductions("Oreochromis niloticus")
#' }
introductions <- endpoint("intrcase")

#' stocks
#' 
#' @return a table of species stocks data
#' @inheritParams species_info
#' @export
#' @examples \donttest{
#' stocks("Oreochromis niloticus")
#' }
stocks <- endpoint("stocks")


## Not indexed by speccode, needs new method
# country <- endpoint("country")
# countryref <- 

