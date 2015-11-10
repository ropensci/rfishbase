#' list_fields
#' 
#' list fields
#' @param fields field (column name) to search for
#' @param  server base URL to the FishBase API (by default). For SeaLifeBase, use http://fishbase.ropensci.org/sealifebase 
#' @param implemented_only by default, only return those tables that have been implemented.  
#' @return a data frame listing the table names (matching function names in rfishbase) and the matching column names those tables have implemented.
#' @details method will use partial matching. Hence "Temp" will match column names such as "TempMin" and "TempMax", but "MinTemp" will not.  Likewise,
#' neither "Minimum" or "Temperature" will match "TempMin", so begin with the shortest query possible and refine based on search results when necessary.
#' Note also that there is no guarentee that the same column has the same value or same meaning in different tables. 
#' @importFrom dplyr filter_
#' @importFrom httr GET 
#' @examples 
#' \dontrun{
#' list_fields("Temp")
#' }
#' @export
list_fields <- function(fields,  server = getOption("FISHBASE_API", FISHBASE_API), implemented_only = TRUE){
  args <- list(fields = fields)
  resp <- httr::GET(paste0(server, "/listfields"), query = args)
  data <- check_and_parse(resp)
  if(is(data, "data.frame") && implemented_only){
    exists <- as.character(lsf.str("package:rfishbase"))
    matches <- unique(data[[1]][data[[1]] %in% exists])
    data <- dplyr::filter_(data, ~TABLE_NAME %in% matches)
  }
  data
}