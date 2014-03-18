#' get the Environment, Climate, and Range of a species.  
#' @param fish.data the fishbase database fish.data or a subset,
#' @param path to cached copy of fishbase (optional, defaults to copy in package).
#' @return a list of the values in the Enviroment / Climate / Range data. See https://github.com/ropensci/rfishbase/issues/13
#' @export
#' @examples \dontrun{
#' library(rfishbase)
#' data(fishbase)
#' out <- getEnviroClimateRange(fish.data[1:3])
#' cat(out[[1]]) # cat for pretty printing
#' } 
getEnviroClimateRange <- function(fish.data=NULL, path=NULL){
  ids <- getIds(fish.data = fish.data, path=path)
  out <- lapply(ids, function(id){
    summaryPage <- getSummary(id)
    xpathSApply(summaryPage, "//h1[ contains(., 'Environment / Climate / Range')]/following::node()[2]/span", xmlValue)
  })
  gsub("\t*\n*\r*", "", out)
}
