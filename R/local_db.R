
#' Cacheable database connection
#' @inheritParams fb_import
#' @param dir directory where database cache will be stored
#' @importFrom fs path dir_create dir_ls
#' @export
fb_conn <- function(server = c("fishbase", "sealifebase"),
                    version =  "latest"){

  
  local <- getOption("rfishbase_local_db", FALSE)
  if(!local) {
    dir <- ":memory:"
  } else {
    dir <- db_dir()
  }
  
  server <- match.arg(server)
  
  if(version == "latest"){
    version <- get_latest_release(server)
  }
  db_name <- paste(server,version, sep="_")
  db <- mget(db_name, envir = rfishbase_cache, ifnotfound = NA)[[1]]
  path <- dir
  if(fs::dir_exists(dir))
    path <- fs::path(dir, db_name)
  if(!inherits(db, "duckdb_connection")){
   db <- DBI::dbConnect(drv = duckdb::duckdb(), path)
   assign(db_name, db, envir = rfishbase_cache)
  }
  db
}

rfishbase_cache <- new.env()

# internal alias
default_db <- fb_conn

#' disconnect the database
#' @param db optional, an existing pointer to the db, e.g. from [fb_conn()]
#' or [fb_import()].
#' @export
db_disconnect <- function(db = NULL){
  if(is.null(db)){
    db_name <- ls(envir = rfishbase_cache)
    if(length(db_name)>0) {
      db <- mget(db_name[[1]], envir = rfishbase_cache, ifnotfound = NA)[[1]]
      rm(db_name, envir = rfishbase_cache)
    }
  }
  if(inherits(db, "duckdb_connection")) {
    DBI::dbDisconnect(db, shutdown=TRUE)
  }
  
}


#' show fishbase directory
#' 
#' @export
#' @importFrom tools R_user_dir
db_dir <- function(){
  dir <- Sys.getenv("FISHBASE_HOME",  tools::R_user_dir("rfishbase"))
  if(!fs::dir_exists(dir)) {
    fs::dir_create(dir)
  }
  dir
}


fish_db <- function(version = "latest"){
  db = fb_conn(version = version)
  fb_import("fishbase", version = version, db)
}
