
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
    if(!is.null(p)){
      tables <- readHTMLTable(p)

      # try again 
      if(length(tables) < 1){
        Sys.sleep(1)
        p <- getFao(summaryPage)
        tables <- readHTMLTable(p)
      }

      if(length(tables) == 1)
        tables[[1]]
      else 
        NULL

    } else 
      NULL
    })
  out
}



getFao <- function(summaryPage){
  link <- try(xpathApply(summaryPage, "//*[contains(@href, '/Country/FaoAreaList.php')][1]", xmlAttrs)[[1]][["href"]])
  if(!is(link, "try-error"))
    ecologyPage <- htmlParse(paste0("http://www.fishbase.org/", gsub("\\.\\./", "", link)))
  else
    NULL
}


