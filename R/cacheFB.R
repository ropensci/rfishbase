# cacheFB.R

#' update the cached copy of fishbase data
#' @return a date-fishdata.Rdat file in the working directory
#' @seealso \code{\link{loadCache}}
#' @details the update is slow, avoiding straining the server or client.
#'   please allow this call to run overnight for a complete upgrade.  
#' @examples
#' ## not run
#' #updateCache()
#' #loadCache()
updateCache <- function(){
  date=Sys.Date()
  file=paste(date, "fishdata.Rdat", sep="")
  fish.data <- getData(1:70000, silent=FALSE)
  save(list="fish.data", file=file)
}

#' loads an updated cache by the date
#' @param date the date of the cache to be loaded,
#'  in yyyy-mm-dd format. 
#' @return loads the object fish.data into the working space. 
#' @seealso \code{\link{updateCache}}
#' @examples
#'  ## not run
#'  #updateCache()
#'  #loadCache()
loadCache <- function(date=Sys.Date()){
  # load a file from the cache
  file=paste(date, "fishdata.Rdat", sep="")
  load(file)
}




