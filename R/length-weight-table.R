
#' get length_weight_table
#' 
#' Gets the length_weight table into R.  (e.g. this table: http://www.fishbase.org/PopDyn/LWRelationshipList.php?ID=2&GenusName=Oreochromis&SpeciesName=niloticus&fc=349). 
#' @param fish.data the fishbase database fish.data or a subset,
#' @param path to cached copy of fishbase (optional, defaults to copy in package).
#' @return a list of tables for each species given.  
#' @export
getLengthWeight <- function(fish.data=NULL, path=NULL){
  ids <- getIds(fish.data = fish.data, path=path)
  out <- lapply(ids, function(id){
    summaryPage <- getSummary(id)
    link <- xpathApply(summaryPage, "//*[contains(@href, '/PopDyn/LWRelationshipList.php')][1]", xmlAttrs)[[1]][["href"]]
    lengthWeightPage <- htmlParse(paste0("http://www.fishbase.org/", gsub("\\.\\./", "", link)))
    tab <- readHTMLTable(lengthWeightPage)[[3]]
    tab$r2 <- as.numeric(gsub("&nbsp", "", tab$r2))
    tab$Score <- NA #need to submit via RHTMLForms for this to evaluate..
    tab
    })
  out

}



