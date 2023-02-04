
#' Cacheable database connection
#' @inheritParams fb_import
fb_conn <- function(server = c("fishbase", "sealifebase"),
                    version =  "latest",
                    dir = db_dir()){

  if(version == "latest"){
    version <- get_latest_release()
  }
  server <- match.arg(server)
  db_name <- paste(server,version, sep="_")
  db <- mget(db_name, envir = rfishbase_cache, ifnotfound = NA)[[1]]
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

db_disconnect <- function(db = NULL){
  if(is.null(db)){
    db_name <- ls(envir = rfishbase_cache)[[1]]
    db <- mget(db_name, envir = rfishbase_cache, ifnotfound = NA)[[1]]
  }
  if(!inherits(db, "duckdb_connection"))
    DBI::dbDisconnect(db, shutdown=TRUE)
}


#' show fishbase directory
#' 
#' @export
#' @importFrom tools R_user_dir
db_dir <- function(){
  Sys.getenv("FISHBASE_HOME",  tools::R_user_dir("rfishbase"))
}


fish_db <- function(version = "latest"){
  db = fb_conn(version = version)
  fb_import("fishbase", version = version, db)
}
