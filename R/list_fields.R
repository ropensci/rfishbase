#' list_fields
#' 
#' list fields
#' @param fields field (column name) to search for
#' @param  server base URL to the FishBase API (by default). For SeaLifeBase, use https://fishbase.ropensci.org/sealifebase 
#' @param implemented_only by default, only return those tables that have been implemented.  
#' @return a data frame listing the table names (matching function names in rfishbase) and the matching column names those tables have implemented.
#' @details 
#' Calling `list_fields()` with no arguments will return the full table of all known fields.
#' Then users can employ standard filter techniques like grep for partial name matching; 
#' see examples.
#' @examples 
#' \donttest{
#' list_fields("Temp")
#' 
#' ## Regex matching on full table
#' library(dplyr)
#' list_fields() %>% filter(grepl("length", columns, ignore.case = TRUE))
#' }
#' @export
list_fields <- function(fields = NULL,  server = NULL, 
                        implemented_only = TRUE){
  if(is.null(fields))
   return(field_list)
  
  field_list %>% filter(columns %in% fields) %>% select(table) %>% distinct()

}