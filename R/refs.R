#' references
#' 
#' @export
#' @param codes One or more Fishbase reference numbers, matching the RefNo 
#' field
#' @inheritParams species
#' @return a tibble (data.frame) of reference data
#' @examples \dontrun{
#' references(codes = 1)
#' references(codes = 1:6)
#' references(codes = 1:6, fields = c('Author', 'Year', 'Title'))
#' }
references <- function(codes = NULL, fields = NULL, 
                       server = getOption("FISHBASE_API", FISHBASE_API), ...){
   out <- left_join(data.frame(RefNo = codes), fb_tbl("refrens"))
   if(!is.null(fields))
     out <- out[fields]
   out
}

# make_citation <- function(x) {
#   as.list(
#     x[c('Author', 'Year', 'Title', 'Source', 'RefType', 'ShortCitation', 'RefNo')]
#   )
# }
