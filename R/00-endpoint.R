
## Allows us to define functions for each endpoint using closures
#' @importFrom dplyr left_join rename sym
#' @importFrom rlang !! .data
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
    
    dplyr::collect(out)
  }
   
}


species_subset <- function(species_list, 
                           full_data, 
                           server = getOption("FISHBASE_API", "fishbase"),
                           version = get_latest_release(),
                           db = default_db()){

  ## load_taxa provides "Genus species"-style species names for a consistent interface
  species <- load_taxa(server, version, db, collect=FALSE) %>% 
    dplyr::select("SpecCode", "Species")
  
  ## "Species" in many tables is just the epithet, we want full species name so drop that.
  if("Species" %in% colnames(full_data)){
    sp <- dplyr::sym("Species")
    full_data <- dplyr::select(full_data, - !!sp)
  }
  
  ## ensure that full_data is a remote table
  if(!inherits(full_data, "src_dbi")){
    tmp <- tmp_tablename()
    dplyr::copy_to(db, df = full_data, name = tmp, overwrite=TRUE, temporary=TRUE) 
    full_data <- dplyr::tbl(db, tmp)
  }
  
  if(is.null(species_list)){
    return(dplyr::left_join(species, full_data, by = "SpecCode"))
  }
    
  ## These are both remote tables now
  speccodes(species_list, table = species, db = db) %>% 
      dplyr::left_join(full_data, by = "SpecCode")
}


## handle ids or species names, returning remote table for joining
speccodes <- function(species_list, table, db){ 
  if(is.integer(species_list)){
    df <- dplyr::tibble(SpecCode = species_list)
  } else {
    df <- dplyr::tibble(Species = species_list)
  }
  
  ## Manually copy. we want a left_join since right_join isn't in RSQLite
  ## but left_join(copy=TRUE) would copy the larger table instead
  tmp <- tmp_tablename()
  dplyr::copy_to(db, df = df, name = tmp, overwrite=TRUE, temporary=TRUE) 
  df <- dplyr::tbl(db, tmp)
  
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
                       version = get_latest_release(),
                       db = default_db(), 
                       ...){
  load_taxa(server, version, db, collect = FALSE, ...) %>% dplyr::select("SpecCode", "Species")
}



tmp_tablename <- function(n=10)
  paste0("tmp_", paste0(openssl::rand_bytes(10), collapse = ""))
