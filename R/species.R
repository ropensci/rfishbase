#' species
#' 
#' Provide wrapper to work with species lists. 
#' @param species_list A vector of scientific names (each element as "genus species"). If empty, a table for all fish will be returned.
#' @param server Either "fishbase" or "sealifebase".
#' @param version a version string for the database. See [available_releases()] for details.
#' @param fields subset to these columns.  (recommend to omit this and handle manually)
#' @param db database connection, now deprecated.
#' @param ... additional arguments, currently ignored
#' @return a data.frame with rows for species and columns for the fields returned by the query (FishBase 'species' table)
#' @details 
#' The Species table is the heart of FishBase. This function provides a convenient way to 
#' query, tidy, and assemble data from that table given an entire list of species.
#' For details, see: http://www.fishbase.org/manual/english/fishbasethe_species_table.htm
#' 
#' Species scientific names are defined according to fishbase taxonomy and nomenclature.
#' @export
#' @examples
#' \dontrun{
#' 
#' species(c("Labroides bicolor", "Bolbometopon muricatum")) 
#' 
#' }
species <- endpoint("species")
