#' get diet (food items table)
#'
#' See the "Food Items" page on Fishbase for the species for details.  
#' @param fish.data the fishbase database fish.data or a subset,
#' @param path to cached copy of fishbase (optional, defaults to copy in package).
#' @return A list of tables with an entry for each fish in fish.data.  
#' @details See example online table for details: http://www.fishbase.org/physiology/OxygenDataList.php?ID=2&GenusName=Oreochromis&SpeciesName=niloticus&fc=349&StockCode=1  
#' @export
#' @examples  \dontrun{
#' data(fishbase)
#' getFoodItems(fish.data[1])
#' }

getFoodItems <- function(fish.data = NULL,
                          path = NULL){

  ids <- getIds(fish.data = fish.data, path=path)
  out <- lapply(ids, function(id){
    summaryPage <- getSummary(id)
    foodItemsPage <- getFoodItemsPage(summaryPage)
    getFoodItemsTable(foodItemsPage)
    })
  species <- fish_names(fish.data, path)
  names(out) <- species
  return(out)
}

getFoodItemsPage <- function(summaryPage){
  link <- xpathApply(summaryPage, "//*[contains(@href, '/TrophicEco/FoodItemsList.php')][1]", xmlAttrs)[[1]][["href"]]
  htmlParse(paste0("http://www.fishbase.org/", gsub("\\.\\./", "", link)))
}


getFoodItemsTable <- function(page){
  tab <- readHTMLTable(page)[[1]]
  names(tab) <- c("Food I",  "Food II", "Food III", 
                  "Food name", "Country", "Predator Stage")
  return(tab)
}
