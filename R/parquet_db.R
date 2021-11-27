

fb_tables <- function(server = c("fishbase", "sealifebase"),
                      version = "latest"){
  
  prov_document <- read_prov(server)
  meta_df <- parse_metadata(prov_document, version = version)
  meta_df$name
}

#' Import tables to local store
#' 
#' @param server fishbase or sealifebase
#' @param version release version
#' @param db A cachable duckdb database connection
#' @param tables list of tables to import. Default `NULL` will
#' import all tables. 
#' @details Downloads and stores tables from the requested version of 
#' fishbase or sealifebase.  If the table is already downloaded, it will
#' not be re-downloaded.  Imported tables are added to the active duckdb
#' connection. Note that there is no need to call this
#' @export
#' @examplesIf interactive()
#' conn <- fb_import()
fb_import <- memoise::memoise(
  function(server = c("fishbase", "sealifebase"),
           version = "latest",
           db = fb_conn(server, version),
           tables = NULL) {
  prov_document <- read_prov(server)
  meta_df <- parse_metadata(prov_document, version = version)
  if(!is.null(tables)){
    meta_df <- meta_df[meta_df$name %in% tables, ]
  }
  ## Resolve data sources (downloading if necessary)
  parquets <- resolve_ids(meta_df$id)
  
  ## re-attempt any
  misses <- is.na(parquets)
  parquets[misses] <- resolve_ids(meta_df$id[misses])
  
  if (any(is.na(parquets)))
    error(paste("Some ids failed to resolve"))
  
  ## Create views in temporary table
  create_views(parquets, meta_df$name, conn = db)
  db
})

## Slowest step, ~ 1.9 seconds even after paths are resolved
## lots of small fs operations to repeatedly determine dirs, sizes, info take time!
## alternately, just cache the connection...
resolve_ids <- memoise::memoise(function(ids) {
  purrr::map_chr(ids,
                 contentid::resolve,
                 store = TRUE,
                 dir = db_dir())
})


parse_metadata <- function(prov, version = version) {
  who <- names(prov)
  if ("@graph" %in% who) {
    prov <- prov[["@graph"]]
  } else {
    prov <- list(prov)
  }
  
  avail_versions <-  map_chr(prov, "version")
  if (version == "latest") {
    version <- max(avail_versions)
  }
  i <- which(version == avail_versions)
  dataset <- prov[[i]]
  
  meta <- dataset$distribution
  meta_df <- tibble::tibble(
    name = map_chr(meta, "name") %>% tools::file_path_sans_ext(),
    id =  map_chr(meta, "id"),
    #  contentSize = map_chr(meta, "contentSize"),
    description = map_chr(meta, "description"),
    format = map_chr(meta, "encodingFormat"),
    type =  map_chr(meta, "type")
  )
  
  
  meta_df[meta_df$type == "DataDownload",]
}

create_views <- function(parquets,
                         tblnames,
                         conn = DBI::dbConnect(drv = duckdb::duckdb())) {
  purrr::walk2(parquets, tblnames, create_view, conn)
  conn
}
create_view <- function(parquet, tblname, conn) {
  if (!tblname %in% DBI::dbListTables(conn)) {
    # query to create view in duckdb to the parquet file
    view_query <- paste0("CREATE VIEW '",
                         tblname,
                         "' AS SELECT * FROM parquet_scan('",
                         parquet,
                         "');")
    DBI::dbSendQuery(conn, view_query)
  }
  conn
}


read_prov <- function(server = c("fishbase", "sealifebase")) {
  server <- match.arg(server)
  prov_latest <-
    switch(server,
           fishbase = "https://github.com/ropensci/rfishbase/raw/master/inst/prov/fb.prov",
           sealifebase = "https://github.com/ropensci/rfishbase/raw/master/prov/slb.prov")
  
  prov_local <-
    switch(
      server,
      fishbase = system.file("prov", "fb.prov", package = "rfishbase"),
      sealifebase = system.file("prov", "slb.prov", package = "rfishbase")
    )
  
  
  prov <- purrr::possibly(jsonlite::read_json,
                          otherwise = jsonlite::read_json(prov_local))
  suppressWarnings({
    out <- prov(prov_latest)
  })
  out
}
