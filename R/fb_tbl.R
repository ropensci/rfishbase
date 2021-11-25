
#' @importFrom memoise memoise
#' @importFrom readr read_tsv cols col_character type_convert
fb_tbl <- 
  function(tbl, 
           server = getOption("FISHBASE_API", "fishbase"), 
           version = "latest",
           db = default_db(server, version),
           collect = FALSE,
           ...){
    db <- parquet_db(server, version, db, tbl)
    out <- dplyr::tbl(db, tbl)
    if(!collect) return(out)
    dplyr::collect(out)
  }

 

has_table <- function(tbl, db = default_db()){
  tbl %in% DBI::dbListTables(db)
}


fb_tbl_endpoint <- function(tbl){
  function(server = getOption("FISHBASE_API", "fishbase"), 
           version = "latest",
           db = default_db(server, version),
           ...){
    db <- parquet_db(server, version, db)
    dplyr::collect(dplyr::tbl(db, tbl))
  }
}





#' @importFrom magrittr %>%
#' @export
magrittr::`%>%`



FISHBASE_API <- "fishbase"