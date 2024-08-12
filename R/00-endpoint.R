
## Allows us to define functions for each endpoint using closures
#' @importFrom dplyr left_join rename sym
#' @importFrom rlang !! .data
endpoint <- function(endpt, join = NULL, by = NULL){
  
  function(species_list = NULL, 
           fields = NULL, 
           server = c("fishbase", "sealifebase"), 
           version = "latest",
           db = NULL,
           ...){
    
    out <- fb_tbl(endpt, server, version) %>% fix_ids()
    
    if(!is.null(species_list)){
      species <-
        fb_tbl("species", server, version) %>%
        dplyr::select("SpecCode", "Genus", "Species") %>%
        dplyr::mutate(sci_name = paste(Genus, Species)) %>%
        dplyr::filter(sci_name %in% species_list) %>%
        dplyr::select(Species=sci_name, "SpecCode")
      
      out <- dplyr::inner_join(species, out) %>% dplyr::distinct()
    }

    if(!is.null(fields)){
      out <- dplyr::select(out, !!fields) %>% dplyr::distinct()
    }
    
    if(!is.null(join)) {
      out <- dplyr::left_join(out, join, by = by)
    }
    out
  }
}

## handle ids or species names, returning remote table for joining
speccodes <- function(species_list, table, db){ 
  if(is.integer(species_list)){
    df <- dplyr::tibble(SpecCode = species_list)
  } else {
    df <- dplyr::tibble(Species = species_list)
  }

  suppressMessages({
  dplyr::left_join(df, table) %>%
    select("SpecCode", "Species")
  })
}



#' @importFrom dplyr sym
fix_ids <- function(full_data){
  if("Speccode" %in% colnames(full_data)){ 
    full_data <- dplyr::rename(full_data, SpecCode = Speccode)
  }
  if("Species" %in% colnames(full_data)){
    sp <- dplyr::sym("Species")
    full_data <- dplyr::select(full_data, - !!sp)
  }
  full_data
}


## Define function that maps sci names to SpecCode, subsets table by requested sci name or spec code
#' @importFrom dplyr mutate select
fb_species <- function(server = getOption("FISHBASE_API", "fishbase"),
                       version = "latest",
                       db = NULL, 
                       ...){
  load_taxa(server, version, db=NULL, collect = FALSE, ...) %>%
    dplyr::select("SpecCode", "Species")
}



tmp_tablename <- function(n=10)
  paste0("tmp_", paste0(sample(letters, n, replace = TRUE), collapse = ""))


utils::globalVariables("sci_name", package="rfishbase")


#' @importFrom magrittr `%>%`
#' @export
magrittr::`%>%`
