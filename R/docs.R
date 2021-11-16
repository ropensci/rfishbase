#' docs
#' 
#' documentation of tables and fields
#' @inheritParams species
#' @param table the table for which the documentation should be displayed.  If no table is given,
#' documentation summarizing all available tables is shown.
#' @return A data.frame which lists the name of each table (if no table argument is given), along with a description
#' of the table and a URL linking to further information about the table.  If a specific table is named in the
#' table argument, then the function will return a data.frame listing all the fields (columns) found in that table, 
#' a description of what the field label means, and the units in which the field is measured.  These descriptions of the
#' columns are not made available by FishBase and must be manually generated and curated by FishBase users. 
#' At this time, many fields are still missing.  Please take a moment to fill in any fields you use in the source
#' table here: https://github.com/ropensci/fishbaseapi/tree/master/docs/docs-sources
#' @importFrom utils read.csv
#' @examplesIf interactive() 
#' \donttest{
#' tables <- docs()
#' # Describe the fecundity table
#' dplyr::filter(tables, table == "fecundity")$description
#' ## See fields in fecundity table
#' docs("fecundity")
#' ## Note: only 
#' }
#' @export
docs <- function(table = NULL, server = NULL, ...){
  
  suppressMessages({
  if(is.null(table)){
    return(read.csv(system.file(file.path("extdata","tables.csv"), 
                                package="rfishbase")))
  }
  read.csv(system.file(file.path("extdata", paste0(table, ".csv")), 
                       package="rfishbase"),
           stringsAsFactors = FALSE)
  })
}

