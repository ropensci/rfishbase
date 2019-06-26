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

#' @importFrom gh gh
#' @importFrom purrr map_chr
#' @importFrom stringr str_extract
get_latest_release <- function() {
  releases <- gh::gh("/repos/:owner/:repo/releases", owner = "ropensci", repo="rfishbase")
  tags <- releases %>% purrr::map_chr("tag_name") 
  latest <- tags %>% stringr::str_extract("\\d\\d\\.\\d\\d") %>% as.numeric() %>% max(na.rm=TRUE)
  as.character(latest)
}

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
