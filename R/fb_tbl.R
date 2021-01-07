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
#' @examples
#' available_releases()
#' options(FISHBASE_VERSION="19.04")
#' ## unset
#' options(FISHBASE_VERSION=NULL)
#' @importFrom stats na.omit
available_releases <- function(){
  

  ## check for cached version first
  avail_releases <- mget("avail_releases", 
                         envir = db_cache, 
                         ifnotfound = NA)[[1]]
  if(!all(is.na(avail_releases)))
    return(avail_releases)
  
  
  ## Okay, check GH for a release
  token <- Sys.getenv("GITHUB_TOKEN", 
                      Sys.getenv("GITHUB_PAT", 
                                 paste0("b2b7441d", 
                                        "aeeb010b", 
                                        "1df26f1f6", 
                                        "0a7f1ed",
                                        "c485e443")))
  avail_releases <- gh::gh("/repos/:owner/:repo/releases", 
         owner = "ropensci",
         repo="rfishbase", 
         .token = token) %>%
    purrr::map_chr("tag_name") %>%
    stringr::str_extract("\\d\\d\\.\\d\\d") %>% 
    as.numeric() %>% 
    stats::na.omit() %>%
    unique() %>% 
    sort(decreasing = TRUE) %>% 
    as.character()
  
  ## Cache this so we don't hit GH every single time!
  assign("avail_releases", avail_releases, envir = db_cache)
  
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
