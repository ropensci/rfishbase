
#' List all fields (column names) in a set of tables
#' 
#' @inheritParams fb_import
#' @param tables list of tables of interest.  Missing tables will be imported
#'  first.  Leave as NULL to query (and thus import) all tables (possibly slow!)
#' @export
#' @return a named list of length(tables). Each element of the list is named
#' for the corresponding table and contains a character vector listing the
#' fields (column names).  
list_fields <- function(server = c("fishbase", "sealifebase"),
                        version = "latest",
                        db = fb_conn(server, version),
                        tables = NULL) {
  
  ## initialize db VIEW of parquet. download tables if needed
  fb_import(server, version, db, tables)
  
  local_tables <- DBI::dbListTables(db)
  names(local_tables) <- local_tables
  fields <- lapply(local_tables, function(x) DBI::dbListFields(db, x))
  fields  
}

