





## Deal with somewhat poorly constructed URL conventions:
prefix <- function(server = getOption("FISHBASE_API", "fishbase")){
  if(is.null(server)) server <- "fishbase"
  dbname <- "fb"
  if(grepl("sealifebase", server)) dbname <- "slb"
  dbname
}


tbl_name <- function(tbl, 
                     server = getOption("FISHBASE_API", "fishbase"), 
                     version = get_latest_release()){
  paste(tbl, prefix(server), gsub("\\.", "", version), sep="_")
}

## Cacheable connection
rfishbase_cache <- new.env()
default_db <- function(server = getOption("FISHBASE_API", "fishbase"),
                       version =  get_latest_release(),
                       cache = TRUE){
  if(!cache) return(DBI::dbConnect(drv = duckdb::duckdb()))
  
  db_name <- paste(server,version, sep="_")
  db <- mget(db_name, envir = rfishbase_cache, ifnotfound = NA)[[1]]
  if(!inherits(db, "duckdb_connection")){
   db <- DBI::dbConnect(drv = duckdb::duckdb())
   assign(db_name, db, envir = rfishbase_cache)
  }
  db
}


db_disconnect <- function(db = NULL){
  if(is.null(db)){
    db_name <- ls(envir = rfishbase_cache)[[1]]
    db <- mget(db_name, envir = rfishbase_cache, ifnotfound = NA)[[1]]
  }
  if(!inherits(db, "duckdb_connection"))
    DBI::dbDisconnect(db, shutdown=TRUE)
}

fish_db <- function(version = "latest"){
  db = default_db(version = version)
  parquet_db("fishbase", version = version, db)
}

#' @importFrom tools R_user_dir
db_dir <- function(){
  Sys.getenv("FISHBASE_HOME",  tools::R_user_dir("rfishbase"))
}
