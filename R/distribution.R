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

#' countrysub
#' 
#' return a table of countrysub for the requested species
#' 
#' @inheritParams species
#' @export
#' @examples \dontrun{
#' countrysub(species_list(Genus='Labroides'))
#' }
countrysub <- endpoint("countrysub")

#' countrysubref
#' 
#' return a table of countrysubref for the requested species
#' 
#' @inheritParams species
#' @export
#' @examples \dontrun{
#' countrysubref(species_list(Genus='Labroides'))
#' }
countrysubref <- endpoint("countrysubref")


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
c_code <- function(c_code, server = getOption("FISHBASE_API", FISHBASE_API), fields=NULL, ...){
   fb_tbl("country") %>% filter(C_code %in% c_code)
}

globalVariables("C_code")


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
distribution <- function(species_list, fields = NULL, 
                         server = getOption("FISHBASE_API", FISHBASE_API),...){
  faoareas(species_list, fields = fields, server = server)
}


#' faoareas
#' 
#' return a table of species locations as reported in FishBASE.org FAO location data
#' 
#' @inheritParams species
#' @importFrom dplyr left_join
#' @export
#' @return a tibble, empty tibble if no results found
#' @examples 
#' \dontrun{
#'   faoareas()
#' }
#' @details currently this is ~ FAO areas table (minus "note" field)
#' e.g. http://www.fishbase.us/Country/FaoAreaList.php?ID=5537
faoareas <- function(species_list = NULL, fields = NULL, server = getOption("FISHBASE_API", FISHBASE_API),...){

  out <- left_join(fb_tbl("faoareas")[c('AreaCode', 'SpecCode', 'Status')],
            faoarrefs()[c('AreaCode', 'FAO')])
  
  species_subset(species_list, out)
}


faoarrefs <- function(){
  fb_tbl("faoarref")
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

