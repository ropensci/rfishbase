#' @importFrom arkdb unark
#' @importFrom utils download.file
#' @importFrom curl curl_download
db_create <- function(tbl, 
                      server = getOption("FISHBASE_API", "fishbase"),
                      version = get_latest_release(),
                      db = default_db(),
                      overwrite = FALSE,
                      ...){
  
  addr <- remote_url(tbl, server, version)
  local_tbl <- paste0(file.path(db_dir(), tbl_name(tbl, server, version)), ".tsv.bz2")
  dir.create(db_dir(), FALSE, TRUE)
  curl::curl_download(addr, dest =  local_tbl)
  
  
  ## FIXME FISHBASE uses mixed-case names for cols that should be case-insensitive
  ## Consider lowercasing all column names (though makes many camelCase names hard to read...)
  arkdb::unark(local_tbl, 
               db, 
               arkdb::streamable_readr_tsv(), 
               overwrite = overwrite,
               guess_max = 1e6
  )
}




## Deal with somewhat poorly constructed URL conventions:
prefix <- function(server = getOption("FISHBASE_API", "fishbase")){
  if(is.null(server)) server <- "fishbase"
  dbname <- "fb"
  if(grepl("sealifebase", server)) dbname <- "slb"
  dbname
}


tag <- function(server = getOption("FISHBASE_API", "fishbase"),
                version = get_latest_release()){
  release <- paste0(prefix(server), "-", version)
}


remote_url <- function(tbl, 
                       server  = getOption("FISHBASE_API", "fishbase"), 
                       version = get_latest_release()){
  paste0("https://github.com/ropensci/rfishbase/releases/download/", 
         tag(server, version), "/", prefix(server), 
         ".2f", tbl, ".tsv.bz2")
}


tbl_name <- function(tbl, 
                     server = getOption("FISHBASE_API", "fishbase"), 
                     version = get_latest_release()){
  paste(tbl, prefix(server), gsub("\\.", "", version), sep="_")
}

#' Connect to the rfishbase database
#' @param dbdir Path to the database.
#' @param driver Default driver, one of "duckdb", "MonetDBLite", "RSQLite".
#'   `rfishbase` will select the first one of those it finds available if a
#'   driver is not set. This fallback can be overwritten either by explicit
#'   argument or by setting the environmental variable `rfishbase_DRIVER`.
#' @return Returns a `src_dbi` connection to the default duckdb database
#' @details This function provides a default database connection for
#' `rfishbase`. Note that you can use `rfishbase` with any DBI-compatible database
#' connection  by passing the connection object directly to `rfishbase`
#' functions using the `db` argument. `default_db()` exists only to provide
#' reasonable automatic defaults based on what is available on your system.
#'
#' `duckdb` or `MonetDBLite` will give the best performance, and regular users
#' `rfishbase` will work with the built-in `RSQlite`, and with other database connections
#' such as Postgres or MariaDB, but queries (filtering joins) will be much slower
#' on these non-columnar databases.
#'
#' For performance reasons, this function will also cache and restore the
#' existing database connection, making repeated calls to `default_db()` much
#' faster and more failsafe than repeated calls to [DBI::dbConnect]
#'
#'
#' @importFrom DBI dbConnect dbIsValid
# @importFrom duckdb duckdb
#' @export
#' @examples \donttest{
#' ## OPTIONAL: you can first set an alternative home location,
#' ## such as a temporary directory:
#' Sys.setenv(FISHBASE_HOME=tempdir())
#'
#' ## Connect to the database:
#' db <- default_db()
#'
#' }
default_db <- function(dbdir = db_dir(),
                       driver = Sys.getenv("DB_DRIVER", "RSQLite")){
  
  arkdb::local_db(dbdir, driver)
  
}

# Some function call is required if RSQLite is in Imports
dummy <- function(){
  RSQLite::rsqliteVersion()
}

#' @importFrom tools R_user_dir
db_dir <- function(){
  Sys.getenv("FISHBASE_HOME",  tools::R_user_dir("rfishbase"))
}
