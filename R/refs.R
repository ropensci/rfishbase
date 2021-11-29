#' references
#' 
#' @export
#' @param codes One or more Fishbase reference numbers, matching the RefNo 
#' field
#' @inheritParams species
#' @return a tibble (data.frame) of reference data
#' @examplesIf interactive()
#' \dontrun{
#' references(codes = 1)
#' references(codes = 1:6)
#' references(codes = 1:6, fields = c('Author', 'Year', 'Title'))
#' references() # all references
#' }
references <- function(codes = NULL, fields = NULL, 
                       server = getOption("FISHBASE_API", "fishbase"), 
                       version = get_latest_release(),
                       db = default_db(), ...){
    out <- fb_tbl("refrens", server, version, db)
    if(!is.null(codes)) out <- dplyr::filter(out, .data$RefNo %in% codes)
    out <- dplyr::collect(out)
    if(!is.null(fields)) out <- out[fields]
    out
}

# make_citation <- function(x) {
#   as.list(
#     x[c('Author', 'Year', 'Title', 'Source', 'RefType', 'ShortCitation', 'RefNo')]
#   )
# }
