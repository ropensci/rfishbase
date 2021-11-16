


parse_metadata <- function(prov, version = version){
  
  who <- names(prov)
  if("@graph" %in% who){
    prov <- prov[["@graph"]]
  } else {
    prov <- list(prov)
  }
  
  avail_versions <-  map_chr(prov, "version")
  if(version == "latest"){
    version <- max(avail_versions)
  }
  i <- which(version == avail_versions)
  dataset <- prov[[i]]

  meta <- dataset$distribution
  meta_df <- tibble::tibble(
    name = map_chr(meta, "name") %>% tools::file_path_sans_ext(),
    id =  map_chr(meta,"id"),
  #  contentSize = map_chr(meta, "contentSize"),
    description = map_chr(meta, "description"),
    format = map_chr(meta, "encodingFormat"),
    type =  map_chr(meta, "type")
  )

    
  meta_df
}

create_views <- function(parquets, tblnames){
  conn <- DBI::dbConnect(drv = duckdb::duckdb())
  purrr::walk2(parquets, tblnames, create_view, conn)
  conn
}
create_view <- function(parquet, tblname, conn){
  if (!tblname %in% DBI::dbListTables(conn)){
    # query to create view in duckdb to the parquet file
    view_query <- paste0("CREATE VIEW '", tblname, 
                         "' AS SELECT * FROM parquet_scan('",
                         parquet, "');")
    DBI::dbSendQuery(conn, view_query)
  }
conn
}


read_prov <- function(app = c("fishbase", "sealifebase")){
  app <- match.arg(app)
  prov_latest <- 
    switch(app, 
           fishbase = "https://github.com/ropensci/rfishbase/raw/master/inst/prov/fb.prov",
           sealifebase = "https://github.com/ropensci/rfishbase/raw/master/prov/slb.prov"
           )

  prov_local <- 
    switch(app, 
           fishbase = system.file("prov", "fb.prov", package="rfishbase"),
           sealifebase = system.file("prov", "slb.prov", package="rfishbase")
           )

  prov <- purrr::possibly(jsonlite::read_json,
                          otherwise = jsonlite::read_json(prov_local))
  prov(prov_latest)
}

import_db <- function(app = c("fishbase", "sealifebase"), version = "latest"){
  prov_document <- read_prov(app)
  parse_metadata(prov_document, version = version)
  ## Resolve data sources (downloading if necessary)
  meta_df$parquets <- map_chr(meta_df$id, contentid::resolve, store=TRUE)
  ## Create views in temporary table
  conn <- create_views(meta_df$parquets, meta_df$title)
}


