
#' fb_tables
#' list tables
#' @inheritParams fb_import
#' @export
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
fb_import <- function(server = c("fishbase","sealifebase"),
                      version=get_latest_release(),
                      db = fb_conn(server, version), 
                      tables = NULL) {
  
  meta <- parse_prov(read_prov(server), version)
  if(!is.null(tables)) {
    meta <- meta[meta$name %in% tables,]
  }
  
  missing <- is.na(meta$url)
  if(any(missing)) {
    meta$url[missing] <- resolve_ids(meta$id[missing])
  }

  
  duckdb_import(meta$url, meta$name, db)
}




parse_prov <- memoise::memoise(
  function(prov = read_prov(), version = "latest") {
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
    name = purrr::map(meta, "name", .default=NA) %>% 
      purrr::map_chr(getElement,1) %>% tools::file_path_sans_ext(),
    id =  purrr::map_chr(meta, "id", .default=NA),
    description = purrr::map_chr(meta, "description", .default=NA),
    format = purrr::map_chr(meta, "encodingFormat", .default=NA),
    type =  purrr::map_chr(meta, "type", .default=NA),
    url =   purrr::map_chr(meta, "contentUrl", .default=NA)
  )
  meta_df[meta_df$type == "DataDownload",]
})

create_views <- function(parquets,
                         tblnames,
                         conn = DBI::dbConnect(drv = duckdb::duckdb())) {
  purrr::walk2(parquets, tblnames, create_view, conn)
  conn
}

read_prov <- memoise::memoise(function(server = c("fishbase", "sealifebase"),
                                       local=getOption("rfishbase_local_prov", 
                                                       FALSE)) {
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
  
  if(local) return(jsonlite::read_json(prov_local))
  
  
  prov <- purrr::possibly(jsonlite::read_json,
                          otherwise = jsonlite::read_json(prov_local))
  suppressWarnings({
    out <- prov(prov_latest)
  })
  out
})


resolve_ids <- memoise::memoise(function(ids) {
  suppressMessages({
    purrr::map_chr(ids,
                   contentid::resolve,
                   store = TRUE,
                   dir = db_dir())
  })
})