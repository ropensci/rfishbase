#' docs
#' 
#' documentation of tables and fields
#' @param table the table for which the documentation should be displayed.  If no table is given,
#' documentation summarizing all available tables is shown.
#' @inheritParams species
#' @return A data.frame which lists the name of each table (if no table argument is given), along with a description
#' of the table and a URL linking to further information about the table.  If a specific table is named in the
#' table argument, then the function will return a data.frame listing all the fields (columns) found in that table, 
#' a description of what the field label means, and the units in which the field is measured.  These descriptions of the
#' columns are not made available by FishBase.org and must be manually generated and curated by FishBase.org users. 
#' At this time, many fields are still missing.  Please take a moment to fill in any fields you use in the source
#' table here: https://github.com/ropensci/fishbaseapi/tree/master/docs/docs-sources
#' @importFrom httr user_agent GET
#' @examples 
#' \dontrun{
#' tables <- docs()
#' # Describe the diet table
#' dplyr::filter(tables, table == "diet")$description
#' }
#' @export
docs <- function(table = "", server = getOption("FISHBASE_API", FISHBASE_API), ...){
    resp <- httr::GET(paste0(server, "/", "docs", table), ..., httr::user_agent(make_ua()))
    check_and_parse(resp)
}