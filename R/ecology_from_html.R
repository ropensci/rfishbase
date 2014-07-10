
#' get trophic level
#'
#' get a quantitative estimate of the trophic level for the species requested. See the "Ecology" page on Fishbase for the speices.  
#' @param fish.data the fishbase database fish.data or a subset,
#' @param path to cached copy of fishbase (optional, defaults to copy in package).
#' @param as_table logical. if True, returns the whole table.  Otherwise (default), returns the element from the table that is specified by the other options.  
#' @param from use the diet composition or the individual food items?  See fishbase.org for details on these differences.  Both may or may not be available.  
#' @param unfished return the estimate for unfished population (default FALSE).  See fishbase.org for details.  
#' @param justSE return the standard deviation to the estimated trophic level.  If FALSE, returns the estimated value, so you must use two calls, or use as_table=TRUE, to get both values.  
#' @param justReference logical. return the reference used for estimation (without other data).  
#' @return depends on the arguments given above.  Default is to return the (fished) diet composition estimate (often used as the default in fishbase.org).  
#' @export
getTrophicLevel <- function(fish.data = NULL,
                            path = NULL,
                            as_table=FALSE, 
                            from = c("diet composition", "individual food items"), 
                            unfished = FALSE,
                            justSE = FALSE,
                            justReference = FALSE){

  ids <- getIds(fish.data = fish.data, path=path)
  out <- sapply(ids, function(id){
    summaryPage <- getSummary(id)
    ecologyPage <- getEcology(summaryPage)
    tab <- readTrophicLevel(ecologyPage)
    if(as_table)
      tab
    else
      parseTrophicLevel(tab, from=from, unfished=unfished,justSE=justSE, justReference=justReference)
    })
  out
}

#' get fishbase id numbers
#'
#' get fishbase id numbers
#' @param fish.data the fishbase database fish.data or a subset,
#' @param path to cached copy of fishbase (optional, defaults to copy in package).
#' @return the ids numbers corresponding to positions along fish.data object in use
#' @import httr
#' @export
getIds <- function(fish.data=NULL, path=NULL){
  if(is.null(fish.data))
    fish.data <- loadCache(path=path)
  ids <- sapply(fish.data, `[[`, 'id')
  species.names <- sapply(fish.data, `[[`, 'ScientificName')
  names(ids) <- gsub(" ", "_", species.names) # use underscores instead of spaces
  ids
}



getSummary <- function(id){ 
  # Grab and parse page matching id
  url <- paste0("http://www.fishbase.org/summary/speciessummary.php?id=", id)
  html <- GET(url)
  summaryPage <- htmlParse(html) 
}

getEcology <- function(summaryPage){
  link <- xpathApply(summaryPage, "//*[contains(@href, '/Ecology/FishEcologySummary.php')][1]", xmlAttrs)[[1]][["href"]]
  html <- GET(paste0("http://www.fishbase.org/", gsub("\\.\\./", "", link)))
  ecologyPage <- htmlParse(html)
}


readTrophicLevel <- function(ecologyPage){ 
  tab <- readHTMLTable(ecologyPage)[[6]]
}

parseTrophicLevel <- function(tab, 
                              from = c("diet composition", "individual food items"), 
                              unfished = FALSE,
                              justSE = FALSE,
                              justReference = FALSE){
  from <- match.arg(from)
  if(justReference)
    out <- as.character(tab[3,2])
  else{
    col <- 2
    adj <- 0
    if(unfished)
      col <- 4
    if(justSE)
      adj <- 1
    if(from == "diet composition")
      out <- as.numeric(as.character(tab[2,col+adj]))
    else if(from == "individual food items")
      out <- as.numeric(as.character(tab[4,col+adj]))
  }
  out 
}



