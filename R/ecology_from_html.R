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
  summaryPage <- htmlParse(url) 
}

getEcology <- function(summaryPage){
  link <- xpathApply(summaryPage, "//*[contains(@href, '/Ecology/FishEcologySummary.php')][1]", xmlAttrs)[[1]][["href"]]
  ecologyPage <- htmlParse(paste0("http://www.fishbase.org/", gsub("\\.\\./", "", link)))
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


#' @export
getTrophicLevel <- function(id,
                            as_table=FALSE, 
                            from = c("diet composition", "individual food items"), 
                            unfished = FALSE,
                            justSE = FALSE,
                            justReference = FALSE){
  summaryPage <- getSummary(id)
  ecologyPage <- getEcology(summaryPage)
  tab <- readTrophicLevel(ecologyPage)
  if(as_table)
    tab
  else
    parseTrophicLevel(tab, from=from, unfished=unfished,justSE=justSE, justReference=justReference)

}





