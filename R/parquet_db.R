


parse_metadata <- function(prov_log = "parquet/fb-2021-06.prov"){
  prov <- jsonlite::read_json(prov_log)
  names(prov[["@graph"]][[1]][[1]])
  meta <- prov[["@graph"]][[1]]
  meta_df <- tibble(
    title = map_chr(meta, "title") %>% tools::file_path_sans_ext(),
    id =  map_chr(meta,"id"),
    wasGeneratedAtTime =  map_chr(meta, "wasGeneratedAtTime"),
    byteSize = map_chr(meta, "byteSize"),
    description = map_chr(meta, "description"),
    format = map_chr(meta, "format"),
    #compressFormat = map_chr(meta, "compressFormat"),
    type =  map_chr(meta, "type")
  )
  ## Filter by date etc?
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

import_db <- function(){
  parse_metadata()
  ## Resolve data sources (downloading if necessary)
  meta_df$parquets <- map_chr(meta_df$id, contentid::resolve, store=TRUE)
  ## Create views in temporary table
  conn <- create_views(meta_df$parquets, meta_df$title)
}


