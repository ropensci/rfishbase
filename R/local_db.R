
#' Cacheable database connection
#' @inheritParams fb_import
fb_conn <- function(server = c("fishbase", "sealifebase"),
                    version =  "latest"){

  server <- match.arg(server)
  db_name <- paste(server,version, sep="_")
  db <- mget(db_name, envir = rfishbase_cache, ifnotfound = NA)[[1]]
  if(!inherits(db, "duckdb_connection")){
   db <- DBI::dbConnect(drv = duckdb::duckdb())
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
  db = default_db(version = version)
  fb_import("fishbase", version = version, db)
}
