
#' get FAO area table  
#'
#' return the FAO data for the required species  
#' @param fish.data the fishbase database fish.data or a subset,
#' @param path to cached copy of fishbase (optional, defaults to copy in package).
#' @return A list of data frames, one per species.    
#' @export
#' @examples 
#' data(fishbase)
#' out <- getFaoArea(fish.data[1:3])
#' 
#' # or using species names:
#' ids <- findSpecies(c("Coris_pictoides", "Labropsis_australis"))
#' out <- getFaoArea(fish.data[ids])
getFaoArea <- function(fish.data = NULL,
                            path = NULL){

  ids <- getIds(fish.data = fish.data, path=path)
  out <- lapply(ids, function(id){
    summaryPage <- getSummary(id)
    p <- getFao(summaryPage)
    readHTMLTable(p)[[1]]
    })
  out
}



getFao <- function(summaryPage){
  link <- xpathApply(summaryPage, "//*[contains(@href, '/Country/FaoAreaList.php')][1]", xmlAttrs)[[1]][["href"]]
  ecologyPage <- htmlParse(paste0("http://www.fishbase.org/", gsub("\\.\\./", "", link)))
}


