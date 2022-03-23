
#' List all fields (column names) in a set of tables
#' 
#' @inheritParams fb_import
#' @param import logical, default FALSE. Should we import missing tables first?
#' @param tables list of tables of interest.  Missing tables will be imported
#'  first if import=TRUE. 
#'  Leave as NULL to query (and thus import) all tables (possibly slow!)
#' @export
#' @return a named list of length(tables). Each element of the list is named
#' for the corresponding table and contains a character vector listing the
#' fields (column names).  
list_fields <- function(import = FALSE,
                        server = c("fishbase", "sealifebase"),
                        version = "latest",
                        db = fb_conn(server, version),
                        tables = NULL) {
  
  
  ## let's download all of rfishbase locally 
  if(import) fb_import(tables, server, version, db)
  
  local_tables <- DBI::dbListTables(db)
  names(local_tables) <- local_tables
  fields <- lapply(local_tables, function(x) DBI::dbListFields(db, x))
  fields  
}

