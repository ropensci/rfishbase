


#' get metabolism table (oxygen consumption).  
#'
#' See the "Metabolism" page on Fishbase for the speices for details.  
#' @param fish.data the fishbase database fish.data or a subset,
#' @param path to cached copy of fishbase (optional, defaults to copy in package).
#' @return A list of tables with an entry for each fish in fish.data.  
#' @details See example online table for details: http://www.fishbase.org/physiology/OxygenDataList.php?ID=2&GenusName=Oreochromis&SpeciesName=niloticus&fc=349&StockCode=1  
#' @export
#' @examples  \dontrun{
#' data(fishbase)
#' getMetabolism(fish.data[1])
#' }

getMetabolism <- function(fish.data = NULL,
                          path = NULL){

  ids <- getIds(fish.data = fish.data, path=path)
  out <- lapply(ids, function(id){
    summaryPage <- getSummary(id)
    metabolismPage <- getMetabolismPage(summaryPage)
    getMetabolismTable(metabolismPage)
    })
  species <- fish_names(fish.data, path)
  names(out) <- species
  out
}

getMetabolismPage <- function(summaryPage){
  link <- xpathApply(summaryPage, "//*[contains(@href, '/physiology/OxygenDataList.php')][1]", xmlAttrs)[[1]][["href"]]
  htmlParse(paste0("http://www.fishbase.org/", gsub("\\.\\./", "", link)))
}


getMetabolismTable <- function(page){
  tab <- readHTMLTable(page)[[1]]
  names(tab) <- c("Oxygen consumption mg/kg/h",  "Oxygen consumption at 20 C", 
                  "Weight (g)", "Temperature C", "Salinity", "Activity",  "Applied stress")
  tab
}
