
#' @export
getEnviroClimateRange <- function(fish.data=NULL, path=NULL){
  ids <- getIds(fish.data = fish.data, path=path)
  out <- lapply(ids, function(id){
    summaryPage <- getSummary(id)
    xpathSApply(summaryPage, "//h1[ contains(., 'Environment / Climate / Range')]/following::node()[2]/span", xmlValue)
  })
  out
}
