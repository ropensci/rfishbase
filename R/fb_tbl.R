#' @importFrom magrittr %>%
#' @export
magrittr::`%>%`


#memoise::cache_filesystem()
#memoise::memoise()




FISHBASE_API <- "fishbase" 



get_release <- function(){
  
  version <- getOption("FISHBASE_VERSION")
  if(is.null(version))
    version <- Sys.getenv("FISHBASE_VERSION")
  if(version == "")
    version <- get_latest_release()
  version
}

#' List available releases
#' 
#' 
#' @details Lists all available releases (year.month format).  
#' To use a specific release, set the desired release using
#' `options(FISHBASE_VERSION=)`, as shown in the examples. 
#' Otherwise, rfishbase will use the latest available version if this
#' option is unset.  NOTE: it will be necessary 
#' to clear the cache with `clear_cache()` or by restarting the R session
#' with a fresh environment.  
#' @export
#' @examplesIf interactive()
#' available_releases()
#' options(FISHBASE_VERSION="19.04")
#' ## unset
#' options(FISHBASE_VERSION=NULL)
#' @importFrom stats na.omit
available_releases <- function(){
  avail_releases <- tryCatch({
    readLines(paste0(
    "https://raw.githubusercontent.com/ropensci/",
     "rfishbase/master/inst/extdata/rfishbase_available_releases.txt"))
    }, 
    error = function(e){
      readLines(system.file("extdata", 
                            "rfishbase_available_releases.txt",
                            package = "rfishbase", mustWork = TRUE))
    },
    finally = readLines(system.file("extdata", 
                                    "rfishbase_available_releases.txt",
                                    package = "rfishbase", mustWork = TRUE)))

  avail_releases
}

#' @importFrom gh gh
#' @importFrom purrr map_chr
#' @importFrom stringr str_extract
get_latest_release <- function() {
  available_releases()[[1]]
}

db_cache <- new.env()

  # "https://fishbase.ropensci.org"
  # <- "https://fishbase.ropensci.org/sealifebase"


has_table <- function(tbl, db = default_db()){
  tbl %in% DBI::dbListTables(db)
}


#' @importFrom memoise memoise
#' @importFrom readr read_tsv cols col_character type_convert
fb_tbl <- 
  function(tbl, 
           server = getOption("FISHBASE_API", "fishbase"), 
           version = get_latest_release(),
           db = default_db(),
           ...){
    db_tbl <- tbl_name(tbl,  server, version)
    if(!has_table(db_tbl)) db_create(tbl, server, version, db)
    dplyr::tbl(db, db_tbl)
    }
