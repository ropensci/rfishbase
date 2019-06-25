#' species
#' 
#' Provide wrapper to work with species lists. 
#' @param species_list A vector of scientific names (each element as "genus species"). If empty, a table for all fish will be returned.
#' @param server can be set to either "fishbase" or "sealifebase" to switch between databases. NOTE: it is usually
#' easier to leave this as NULL and set the source instead using the environmental variable `FISHBASE_API`, e.g.
#' `Sys.setenv(FISHBASE_API="sealifebase")`.
#' @param fields a character vector specifying which fields (columns) should be returned. By default,
#'  all available columns recognized by the parser are returned.  Mostly for backwards compatibility as users can subset by column later
#' @param ... unused; for backwards compatibility only
#' @return a data.frame with rows for species and columns for the fields returned by the query (FishBase 'species' table)
#' @details 
#' The Species table is the heart of FishBase. This function provides a convenient way to 
#' query, tidy, and assemble data from that table given an entire list of species.
#' For details, see: http://www.fishbase.org/manual/english/fishbasethe_species_table.htm
#' 
#' Species scientific names are defined according to fishbase taxonomy and nomenclature.
#' 
#' @importFrom methods as is
#' @importFrom utils data lsf.str packageVersion
#' @export species
#' @aliases species species_info
#' @examples
#' \dontrun{
#' 
#' species(c("Labroides bicolor", "Bolbometopon muricatum")) 
#' species(c("Labroides bicolor", "Bolbometopon muricatum"), fields = species_fields$habitat) 
#' 
#' }
species <- function(species_list = NULL, fields = NULL, 
                    server = NULL, ...){
  full_data <- fb_tbl("species", server) %>% 
    select(-Genus, -Species)
  
  full_data <- fix_ids(full_data)
  out <- species_subset(species_list, full_data, server)
  
  if(!is.null(fields)){
    out <- out[fields]
  }
  
  out
}

#species <- endpoint("species", tidy_table = tidy_species_table)

load_species_meta <- memoise::memoise(function(){
  meta <- system.file("metadata", "species.csv", package="rfishbase")
  species_meta <- as.data.frame(readr::read_csv(meta, col_types = "cclc"))
  row.names(species_meta) <- species_meta$field
  species_meta
})

## helper routine for tidying species data
tidy_species_table <- function(df) {
  

  species_meta <- load_species_meta()
  # Convert columns to the appropriate class
  for(i in names(df)){
    class <- as.character(species_meta[[i, "class"]])
    if(class=="Date"){
      df[[i]] <- as.Date(df[[i]])
    } else if(class=="logical"){
      df[[i]] <- as(as.numeric(as.character(df[[i]])), class)
    } else {
      df[[i]] <- as(as.character(df[[i]]), class) 
      # Will warn when class=integer & value is NA
    }
  }
  ## Drop useless columns. 
  # keep <- species_meta$field[species_meta$keep]
  # keep_id <- match(keep, names(df))
  # keep_id <- keep_id[!is.na(keep_id)]
  # df <- df[,keep_id]
  
  ## Rename columns (pick names to indicate units on numeric values?)
  
  ## Arrange columns
  
  df
}
## Metadata used by tidy_species_table, created into data_raw()




#' A list of the species_fields available
#'
#' @name species_fields
#' @docType data
#' @author Carl Boettiger \email{carl@@ropensci.org}
#' @references \url{http://fishbase.org}
#' @keywords data
NULL



