## Consider information from: Countries | FAO areas | Ecosystems | Occurrences | Point map | Introductions | Faunaf

default_db <- function() NULL

# avoid globals
DateEntered <- NA
Datemodified <- NA
Datechecked <- NA
E_CODE <- NA
Ecosystemname <- NA


#' country
#' 
#' return a table of country for the requested species, as reported in FishBASE.org 
#' 
#' @inheritParams species
#' @export
#' @examplesIf interactive() 
#' \dontrun{
#' country("Bolbometopon muricatum")
#' }
#' @details 
#' e.g. http://www.fishbase.us/Country
country <- endpoint("country", join = country_names())

#' countrysub
#' 
#' return a table of countrysub for the requested species
#' 
#' @inheritParams species
#' @export
#' @examplesIf interactive() 
#' \dontrun{
#' countrysub(species_list(Genus='Labroides'))
#' }
countrysub <- endpoint("countrysub", join = country_names())

#' countrysubref
#' 
#' return a table of countrysubref
#' @inheritParams species
#' @export
#' @examplesIf interactive() 
#' \dontrun{
#' countrysubref()
#' }
countrysubref <- function(server = getOption("FISHBASE_API", "fishbase"), 
                          version = get_latest_release(),
                          db = default_db(),
                          ...){
  fb_tbl("countrysubref", server, version, db) %>% left_join(country_names())
}


#' c_code
#' 
#' return a table of country information for the requested c_code, as reported in FishBASE.org 
#' 
#' @inheritParams species
#' @param c_code a C_Code or list of C_Codes (FishBase country code)
#' @export
#' @examplesIf interactive() 
#' \dontrun{
#' c_code(440)
#' }
#' @details 
#' e.g. http://www.fishbase.us/Country
c_code <- function(c_code = NULL, 
                   server = getOption("FISHBASE_API", "fishbase"), 
                   version = get_latest_release(),
                   db = default_db(), 
                   ...){
  
  out <- 
    fb_tbl("countrysubref", server, version, db) %>% 
    left_join(country_names(server, version, db))
  
  if(is.null(c_code)) 
    out
  else
    out %>% filter(C_Code %in% c_code)
}

globalVariables(c("C_Code", "PAESE"))

country_names <- function(server = getOption("FISHBASE_API", "fishbase"), 
                          version = "latest",
                          db = NULL){
  fb_tbl("countref", server, version, db) %>% 
    select(country = PAESE, C_Code)
}


#' faoareas
#' 
#' return a table of species locations as reported in FishBASE.org FAO location data
#' 
#' @inheritParams species
#' @importFrom dplyr left_join
#' @export
#' @return a tibble, empty tibble if no results found
#' @examplesIf interactive() 
#' \dontrun{
#'   faoareas()
#' }
#' e.g. http://www.fishbase.us/Country/FaoAreaList.php?ID=5537
faoareas <- function(species_list = NULL, fields = NULL, 
                     server = getOption("FISHBASE_API", "fishbase"), 
                     version = "latest",
                     db = NULL,
                     ...){
  area <- fb_tbl("faoareas", server, version)
  ref <- faoarrefs(server, version)
  out <- left_join(area, ref, by = "AreaCode")
  out <- select_fields(out, fields)
  species_subset(species_list, out, server=server, version=version)
}

select_fields <- function(df, fields = NULL){
  if (is.null(fields)) return(df)
  do.call(dplyr::select, 
           c(list(df), as.list(c("SpecCode", fields))))
}

faoarrefs <- function(server = getOption("FISHBASE_API", "fishbase"), 
                      version = "latest",
                      db = NULL){
  fb_tbl("faoarref", server, version, db)
}


## FIXME: Reproduce the ECOSYSTEMS table: 
# see `ecosystem` sql-table
# http://www.fishbase.us/trophiceco/EcosysList.php?ID=5537

#' ecosystem
#' 
#' @return a table of species ecosystems data
#' @inheritParams species
#' @export
#' @examplesIf interactive() 
#' \dontrun{
#' ecosystem("Oreochromis niloticus")
#' }
ecosystem <-  function(species_list = NULL, 
                       fields = NULL, 
                       server = getOption("FISHBASE_API", "fishbase"), 
                       version = "latest",
                       db = NULL,
                       ...){
  endpt = "ecosystem"
  join = fb_tbl("ecosystemref", server = server, version = version)
  by = "E_CODE"
  full_data <- fb_tbl(endpt, server, version, db) %>% fix_ids()
  out <- species_subset(species_list, full_data, server, version, db)
  out <- rename(out, DateEntered = Dateentered,
    DateModified = Datemodified, DateChecked = Datechecked)
  if(!is.null(fields)){
    out <- select(out, !!fields)
  }
  if(!is.null(join))
    out <- left_join(out, join, by = by)
  dplyr::collect(out)
}

#' Species list by ecosystem
#' 
#' @return a table of species ecosystems data
#' @inheritParams species
#' @param ecosystem (character) an ecosystem name
#' @export
#' @examplesIf interactive() 
#' \dontrun{
#' species_by_ecosystem(ecosystem = "Arctic", server = "sealifebase")
#' }
species_by_ecosystem <- function(ecosystem, species_list = NULL,
  server = getOption("FISHBASE_API", "fishbase"),
  version = "latest", db = NULL, ...) {

  ecosysref = fb_tbl("ecosystemref", server, version, db)
  ecosysname <- dplyr::filter(ecosysref, EcosystemName == ecosystem)
  if (dplyr::collect(dplyr::count(ecosysname))$n == 0)
    stop("ecosystem '", ecosystem, "' not found", call. = FALSE)
  ecosys <- fb_tbl("ecosystem", server, version, db) %>% fix_ids()
  e_code <- dplyr::collect(ecosysname)$E_CODE
  out <- dplyr::filter(ecosys, E_CODE == e_code)
  species <- dplyr::select(load_taxa(server, version, db, collect=FALSE), "SpecCode", "Species")
  out <- dplyr::left_join(out, species, by = "SpecCode")
  out <- dplyr::left_join(out, dplyr::select(ecosysref, E_CODE, EcosystemName),
    by = "E_CODE")
  out <- dplyr::relocate(out, E_CODE, EcosystemName, SpecCode, Species)
  dplyr::collect(out)
}

species_subset <- function(species_list, full_data, server, version, db=NULL) {
  codes <- fb_species(server, version) |> 
    dplyr::filter(Species %in% species_list)
  
  full_data |> dplyr::inner_join(codes)
}


#' introductions
#' 
#' @return a table of species introductions data
#' @inheritParams species
#' @export
#' @examplesIf interactive() 
#' \dontrun{
#' introductions("Oreochromis niloticus")
#' }
introductions <- endpoint("intrcase")

#' stocks
#' 
#' @return a table of species stocks data
#' @inheritParams species
#' @export
#' @examplesIf interactive() 
#' \dontrun{
#' stocks("Oreochromis niloticus")
#' }
stocks <- endpoint("stocks")

## Not indexed by speccode, needs new method
# country <- endpoint("country")
# countryref <- 

