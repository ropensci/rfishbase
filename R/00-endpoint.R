
## Allows us to define functions for each endpoint using closures
#' @importFrom dplyr left_join rename sym
#' @importFrom rlang !!
endpoint <- function(endpt, join = NULL, by = NULL){
  
  function(species_list = NULL, 
           fields = NULL, 
           server = getOption("FISHBASE_API", "fishbase"), 
           version = get_latest_release(),
           db = default_db(),
           ...){
    
    
    full_data <- fb_tbl(endpt, server, version, db) %>% fix_ids()

    out <- species_subset(species_list, full_data, server, version, db)
    
    if(!is.null(fields)){
      out <- select(out, !!fields)
    }
    
    if(!is.null(join))
      out <- left_join(out, join, by = by)
    
    out
  }
}


species_subset <- function(species_list, 
                           full_data, 
                           server = getOption("FISHBASE_API", "fishbase"),
                           version = get_latest_release(),
                           db = default_db()){

  species <- load_taxa(server, version, db) %>% dplyr::select("SpecCode", "Species")
  if(is.null(species_list)){
    return(dplyr::left_join(species, full_data, by = "SpecCode"))
  }
    
  ## 
  suppressMessages({
    speccodes(species_list, table = species) %>% 
    dplyr::copy_to(db, "species_list", overwrite=TRUE, temporary=TRUE) 
    dplyr::tbl(db, "species_list") %>% 
      dplyr::left_join(species, by = "SpecCode") %>%
      dplyr::left_join(full_data, by = "SpecCode")
  })
  out
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
                       version = get_latest_release(),
                       db = default_db(), 
                       ...){
  load_taxa(server, version, db, ...) %>% dplyr::select("SpecCode", "Species")
}

