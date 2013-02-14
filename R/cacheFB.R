# cacheFB.R

#' Update the cached copy of fishbase data
#' @param path where cache should be stored. (default to working directory)
#' @return a date-fishdata.Rdat file.  
#' @seealso \code{\link{loadCache}}
#' @details the update is slow, avoiding straining the server or client.
#'   please allow this call to run overnight for a complete upgrade.  
#' @keywords cache
#' @examples \dontrun{
#'  updateCache()
#'  loadCache()
#' }
#' @export
updateCache <- function(path="."){
  date=Sys.Date()
  file=paste(path, "/", date, "fishdata.Rdat", sep="")
  fish.data <- getData(1:70000, silent=FALSE)
  save(list="fish.data", file=file)
}

#' Load an updated cache
#' @param path location where cache is located
#' @return loads the object fish.data into the working space. 
#' @seealso \code{\link{updateCache}}
#' @keywords cache
#' @examples \dontrun{
#'  updateCache()
#'  loadCache()
#' }
#' @export
loadCache <- function(path=NULL){
  if(is.null(path))
  file <- system.file("data", "fishbase.rda", package="rfishbase")
  else {
  # load the most recent file from the cache
  files <- list.files(path) 
  copies <- grep("fishdata.Rdat", files)
  most_recent <- files[copies[length(copies)]]
  file=paste(path, "/", most_recent, sep="")
  }
  load(file, envir = fishbaseCache)
  fish.data <- get("fish.data", envir = fishbaseCache)
  fish.data
}




