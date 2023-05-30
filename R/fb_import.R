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
