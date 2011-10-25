

#' remove non-ASCII characters
#' @param string any character string
#' @return the string after dropping all html tags to spaces
#' @keywords internal
drop_nonascii <- function(string){
  string <- gsub("\302\260", " (degrees )", string)
  string
}

#' clean the fish.base data into pure ASCII
#' @param a list item with fishbase data
#' @return the item scrubbed of non-ASCII characters
#' @keywords internal
clean_data <- function(fish.data){
  for(i in 1:length(fish.data)){
    for(j in 1:length(fish.data[[i]])){
      fish.data[[i]][[j]] <- drop_nonascii(fish.data[[i]][[j]])
    }
  }
}
