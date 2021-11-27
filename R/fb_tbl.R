#' 
#' Access a fishbase or sealifebase table
#' @param tbl table name, as it appears in the database. See [fb_tables()]
#' for a list.
#' @param collect should we return an in-memory table? Generally best to leave
#' as TRUE unless RAM is too limited.  A remote table can be used with most
#' dplyr functions (filter, select, joins, etc) to further refine.
#' @inheritParams fb_import
#' @export
#' @examplesIf interactive()
#' fb_tbl("species")
fb_tbl <- 
  function(tbl, 
           server = c("fishbase", "sealifebase"), 
           version = "latest",
           db = fb_conn(server, version),
           collect = TRUE,
           ...){
    db <- fb_import(server, version, db, tbl)
    out <- dplyr::tbl(db, tbl)
    if(!collect) return(out)
    dplyr::collect(out)
  }

 
#' @importFrom magrittr `%>%`
#' @export
magrittr::`%>%`
FISHBASE_API <- "fishbase"