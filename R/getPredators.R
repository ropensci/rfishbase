#' get Predators table
#'
#' return the Predators data for the required species
#' @param fish.data the fishbase database fish.data or a subset,
#' @param path to cached copy of fishbase (optional, defaults to copy in package).
#' @return A list of data frames, one per species.
#' @import httr
#' @export
#' @examples

getPredators <- function(fish.data = NULL,
                         path = NULL,
                         functl.grp = NULL){
  ids <- getIds(fish.data = fish.data, path=path)
  out <- lapply(ids, function(id){
  summaryPage <- getSummary(id)
  p <- getPredatorURL(summaryPage)
  if(!is.null(p)){
    tables <- readHTMLTable(p)

    # try again
    if(length(tables) < 1){
      Sys.sleep(1)
      p <- getPredatorURL(summaryPage)
      tables <- readHTMLTable(p)
    }

    if(length(tables) == 1){
      table <- tables[[1]]
      names(table) <- c("Country", "Functional_Grp_General", "Functional_Grp_Specific", "Family", "Species")
    }
    else
      NULL

  } else
    NULL
  })
  out
}


getPredatorURL <- function(summaryPage){
  link <- try(xpathApply(summaryPage, "//*[contains(@href, '/TrophicEco/PredatorList.php')][1]", xmlAttrs)[[1]][["href"]])
  if(!is(link, "try-error")){
    html <- GET(paste0("http://www.fishbase.org/", gsub("\.\./", "", link)))
    predatorPage <- htmlParse(html)
  } else
  NULL
}
