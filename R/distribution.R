## Consider information from: Countries | FAO areas | Ecosystems | Occurrences | Point map | Introductions | Faunaf


#' country
#' 
#' return a table of country for the requested species, as reported in FishBASE.org 
#' 
#' @inheritParams species
#' @export
#' @examples \dontrun{
#' country(species_list(Genus='Labroides'))
#' }
#' @details 
#' e.g. http://www.fishbase.us/Country
country <- endpoint("country")



#' c_code
#' 
#' return a table of country information for the requested c_code, as reported in FishBASE.org 
#' 
#' @inheritParams species
#' @param c_code a C_Code or list of C_Codes (FishBase country code)
#' @export
#' @examples \dontrun{
#' c_code(440)
#' }
#' @details 
#' e.g. http://www.fishbase.us/Country
c_code <- function(c_code, server = getOption("FISHBASE_API", FISHBASE_API), fields='', limit = 500){
  resp <- httr::GET(paste0(server, "/faoareas"), 
                    query = list(C_Code = c_code, limit = limit,
                                 fields),
                    httr::user_agent(make_ua()))  
  check_and_parse(resp)
}



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
distribution <- function(species_list, fields = NULL, server = getOption("FISHBASE_API", FISHBASE_API), limit = 500){
  faoareas(species_list, fields = fields, server = server, limit = limit)
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
faoareas <- function(species_list, fields = NULL, server = getOption("FISHBASE_API", FISHBASE_API), limit = 500){
  codes <- speccodes(species_list)
  
  faoareas_get <- c('AreaCode', 'SpecCode', 'Status')
  faoarrefs_get <- c('AreaCode', 'FAO')
  
  faoareas_fl <- paste0(if (!is.null(fields)) c(faoareas_get, fields) else faoareas_get, collapse = ",")
  dplyr::bind_rows(lapply(codes, function(code) {
    resp <- httr::GET(paste0(server, "/faoareas"), 
                      query = list(SpecCode = code, limit = limit, fields = faoareas_fl),
                      httr::user_agent(make_ua()))
    table1 <- check_and_parse(resp)
    
    ## Look up area codes
    table2 <- dplyr::bind_rows(lapply(table1$AreaCode, function(x) {
      faoarrefs_fl <- paste0(if (!is.null(fields)) c(faoarrefs_get, fields) else faoarrefs_get, collapse = ",")
      faoarrefs(x, fields = faoarrefs_fl, server = server, limit = limit)
    }))
    dplyr::left_join(table1, table2, by = 'AreaCode')
  }))
}


faoarrefs <- function(area_code, fields = NULL, server = getOption("FISHBASE_API", FISHBASE_API), limit = 100){
  resp <- httr::GET(paste0(server, "/faoarref/", area_code), 
              query = list(limit = limit, fields = fields),
              user_agent(make_ua()))
  check_and_parse(resp)
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
#' @details THE OCCURRENCE TABLE HAS BEEN DROPPED BY FISHBASE - THIS
#' FUNCTION NOW RETURNS A STOP MESSAGE.
#' @export
occurrence <- function() {
  stop("occurrence is no longer available", call. = FALSE)
  #endpoint("occurrence")
}

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

