#' @importFrom arkdb unark
#' @importFrom utils download.file
db_create <- function(tbl, 
                      server = getOption("FISHBASE_API", "fishbase"),
                      version = get_latest_release(),
                      db = default_db(),
                      overwrite = FALSE,
                      ...){
  
  addr <- remote_url(tbl, server, version)

  local_tbl <- file.path(db_dir(), tbl_name(tbl, server, version))
  dir.create(db_dir(), FALSE, TRUE)
  utils::download.file(addr, dest =  local_tbl)
  
  
  ## FIXME FISHBASE uses mixed-case names for cols that should be case-insensitive
  ## Consider lowercasing all column names (though makes many camelCase names hard to read...)
  arkdb::unark(local_tbl, 
               db, 
               arkdb::streamable_readr_tsv(), 
               overwrite = overwrite,
               col_types = readr::cols(.default = "c")
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
#' db <- connect_db()
#'
#' }
default_db <- function(dbdir = db_dir(),
                       driver = Sys.getenv("DB_DRIVER")){
  
  db_path <- file.path(dbdir, "database")
  db <- mget("local_db", envir = db_cache, ifnotfound = NA)[[1]]
  if (inherits(db, "DBIConnection")) {
    if (DBI::dbIsValid(db)) {
      return(db)
    }
  }
  dir.create(db_path, showWarnings = FALSE, recursive = TRUE)
  db <- db_driver(db_path, driver)
  assign("local_db", db, envir = db_cache)
  db
}


## Only duckdb supports simultaneous connections
db_driver <- function(dbname, driver = Sys.getenv("DB_DRIVER")){
  
  ## Evaluate capabilities in reverse-priorty order
  drivers <- "dplyr"
  
  if (requireNamespace("RSQLite", quietly = TRUE)){
    SQLite <- getExportedValue("RSQLite", "SQLite")
    drivers <- c("RSQLite", drivers)
  }
#  if (requireNamespace("MonetDBLite", quietly = TRUE)){
#    MonetDBLite <- getExportedValue("MonetDBLite", "MonetDBLite")
#    drivers <- c("MonetDBLite", drivers)  ## lacks concat_ws (paste)
#  }
 
#  if (requireNamespace("duckdb", quietly = TRUE)){
#      duckdb <- getExportedValue("duckdb", "duckdb")
#      drivers <- c("duckdb", drivers)  
#  }
  
  ## If driver is undefined or not in available list, use first from the list
  if (  !(driver %in% drivers) ) driver <- drivers[[1]]
  
  switch(driver,
#         duckdb = DBI::dbConnect(duckdb(),
#                                       dbname = file.path(dbname,"duckdb")),
#         MonetDBLite = monetdblite_connect(file.path(dbname,"MonetDBLite")),
         RSQLite = DBI::dbConnect(SQLite(),
                                        file.path(dbname, "sqlite_db.sqlite")),
         dplyr = NULL,
         NULL)
}


# Provide an error handler for connecting to monetdblite if locked by another session
# @importFrom MonetDBLite MonetDBLite
monetdblite_connect <- function(dbname, ignore_lock = TRUE){
  #if (requireNamespace("MonetDBLite", quietly = TRUE))
  MonetDBLite <- getExportedValue("MonetDBLite", "MonetDBLite")
  db <- tryCatch({
    if (ignore_lock) unlink(file.path(dbname, ".gdk_lock"))
    DBI::dbConnect(MonetDBLite(), dbname = dbname)
  },
  error = function(e){
    if(grepl("Database lock", e))
      stop(paste("Local database is locked by another R session.\n",
                 "Try closing that session first or set the DB_HOME\n",
                 "environmental variable to a new location.\n"),
           call. = FALSE)
    else stop(e)
  },
  finally = NULL
  )
  db
}

db_disconnect <- function(env = db_cache){
  db <- mget("local_db", envir = env, ifnotfound = NA)[[1]]
  if (inherits(db, "DBIConnection")) {
    suppressWarnings(
      DBI::dbDisconnect(db)
    )
  }
}

## Enironment to store the cached copy of the connection
## and a finalizer to close the connection on exit.
db_cache <- new.env()
reg.finalizer(db_cache, db_disconnect, onexit = TRUE)

#' @importFrom rappdirs user_data_dir
db_dir <- function(){
  Sys.getenv("FISHBASE_HOME",  rappdirs::user_data_dir("rfishbase"))
}
