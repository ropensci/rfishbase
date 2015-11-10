## Consider information from: Countries | FAO areas | Ecosystems | Occurrences | Point map | Introductions | Faunaf

#' distribution
#' 
#' return a table of species locations as reported in FishBASE.org FAO location data
#' 
#' @inheritParams species
#' @export
#' @examples \dontrun{
#' distribution(species_list(Genus='Labroides'))
#' }
#' @details currently this is ~ FAO areas table (minus "note" field)
#' e.g. http://www.fishbase.us/Country/FaoAreaList.php?ID=5537
distribution <- function(species_list, server = getOption("FISHBASE_API", FISHBASE_API), limit = 500){
  faoareas(species_list, server = server, limit = limit)
}


#' faoareas
#' 
#' return a table of species locations as reported in FishBASE.org FAO location data
#' 
#' @inheritParams species
#' @importFrom dplyr bind_rows left_join
#' @importFrom httr GET
#' @export
#' @examples 
#' \dontrun{
#'   faoareas(species_list(Genus='Labroides'))
#' }
#' @details currently this is ~ FAO areas table (minus "note" field)
#' e.g. http://www.fishbase.us/Country/FaoAreaList.php?ID=5537
faoareas <- function(species_list, server = getOption("FISHBASE_API", FISHBASE_API), limit = 500){
  codes <- speccodes(species_list)
  out <- dplyr::bind_rows(lapply(codes, function(code){
  
  resp <- httr::GET(paste0(server, "/faoareas"), 
              query = list(SpecCode = code, limit = limit,
                           fields='AreaCode,SpecCode,Status'),
              user_agent(make_ua()))  
  table1 <- check_and_parse(resp)
  
  ## Look up area codes
  table2 <- dplyr::bind_rows(lapply(table1$AreaCode, faoarrefs))
  dplyr::left_join(table1, table2,by='AreaCode')
  ## cbind
  
  }))
  
  out
}


faoarrefs <- function(area_code, server = getOption("FISHBASE_API", FISHBASE_API), limit = 100){
  ## add in a fields list to filter returned values
  resp <- httr::GET(paste0(server, "/faoarref/", area_code), 
              query = list(limit = limit,
                           fields='AreaCode,FAO'),
              user_agent(make_ua()))
  data <- check_and_parse(resp)
}


## FIXME: Reproduce the ECOSYSTEMS table: 
# see `ecosystem` sql-table
# http://www.fishbase.us/trophiceco/EcosysList.php?ID=5537

#' ecosystem
#' 
#' @return a table of species ecosystems data
#' @inheritParams species
#' @export
#' @examples \dontrun{
#' ecosystem("Oreochromis niloticus")
#' }
ecosystem <- endpoint("ecosystem")

#' occurrence
#' 
#' @return a table of species occurrence data
#' @inheritParams species
#' @export
#' @examples \dontrun{
#' occurrence("Oreochromis niloticus")
#' }
occurrence <- endpoint("occurrence")

#' introductions
#' 
#' @return a table of species introductions data
#' @inheritParams species
#' @export
#' @examples \dontrun{
#' introductions("Oreochromis niloticus")
#' }
introductions <- endpoint("intrcase")

#' stocks
#' 
#' @return a table of species stocks data
#' @inheritParams species
#' @export
#' @examples \dontrun{
#' stocks("Oreochromis niloticus")
#' }
stocks <- endpoint("stocks")


## Not indexed by speccode, needs new method
# country <- endpoint("country")
# countryref <- 

