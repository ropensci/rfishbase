#' synonyms
#'
#' Check for alternate versions of a scientific name
#' @inheritParams species
#' @return A table with information about the synonym. Will generally be only a single
#' row if a species name is given.  If a FishBase SpecCode is given, all synonyms matching
#' that SpecCode are shown, and the table indicates which one is Valid for FishBase. This may
#' or may not match the valid name for Catalog of Life (Col), also shown in the table. See examples for details.
#' @details
#' For further information on fields returned, see:
#' http://www.fishbase.org/manual/english/fishbasethe_synonyms_table.htm
#' @export
# @examples
# \donttest{
# # Query using a synonym:
# synonyms("Callyodon muricatus")
#
#  # Check for misspellings or alternate names
#  synonyms("Labroides dimidatus") # Species name misspelled
#
#  # See all synonyms
#  species("Bolbometopon muricatum")
#  }
synonyms <- function(species_list = NULL,
                     server = getOption("FISHBASE_API", "fishbase"),
                     version = get_latest_release(),
                     db = default_db(),
                     ...){

  if (is.null(server))
    server <- getOption("FISHBASE_API", FISHBASE_API)
  if (!grepl("sealifebase", server)) {
    syn <-
      fb_tbl("synonyms", server, version, db) %>%
      mutate(synonym = paste(SynGenus, SynSpecies)) %>%
      select(synonym, Status, SpecCode, SynCode,
             CoL_ID, TSN, WoRMS_ID, ZooBank_ID,
             TaxonLevel)
  } else {
    syn <-
      fb_tbl("synonyms", server, version, db) %>%
      mutate(synonym = paste(SynGenus, SynSpecies)) %>%
      select("synonym", "Status", "SpecCode", "SynCode",
             "CoL_ID", "TSN", "ZooBank_ID",
             "TaxonLevel")

 }

  if(is.null(species_list))
    return(collect(syn))

  df <- data.frame(synonym = species_list, stringsAsFactors = FALSE)
  tmp <- tmp_tablename()
  dplyr::copy_to(db, df = df, name = tmp, overwrite=TRUE, temporary=TRUE)
  df <- dplyr::tbl(db, tmp)

  left_join(df, syn, by="synonym") %>%
    left_join(fb_species(server, version, db), by = "SpecCode") %>%
    collect()
}


globalVariables(c("Status", "SpecCode", "SynCode",
"CoL_ID", "TSN", "WoRMS_ID", "ZooBank_ID",
"TaxonLevel", "synonym", "SynGenus", "SynSpecies", "columns"))

#' validate_names
#'
#' Check for alternate versions of a scientific name and return
#' the scientific names FishBase recognizes as valid
#' @inheritParams species
#' @return a string of the validated names
#' @export
#' @importFrom dplyr filter pull right_join
#' @examplesIf interactive()
#'  \donttest{
#' validate_names("Abramites ternetzi")
#' }
validate_names <- function(species_list,
                           server = getOption("FISHBASE_API", "fishbase"),
                           version = get_latest_release(),
                           db = default_db(),
                           ...){
  rx <- "^[sS]ynonym$|^accepted name$"
  tmp <- data.frame(synonym  = species_list, stringsAsFactors = FALSE)
  synonyms(species_list, server = server, version = version, db = db) %>%
    dplyr::collect() %>%
    dplyr::mutate(Species = ifelse(grepl(rx, Status), Species, NA)) %>%
    # group by input taxon, remove NAs
    dplyr::group_by(synonym) %>%
    dplyr::filter(!is.na(Species)) %>%
    dplyr::ungroup() %>%
    dplyr::select(synonym, Species) %>% 
    dplyr::distinct() %>%
    # left_join to tmp to preserve species order from tmp
    dplyr::left_join(x = tmp, y = ., by = "synonym") %>% 
    dplyr::pull(Species)
}

utils::globalVariables(".", package="rfishbase")
