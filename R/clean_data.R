#' remove non-ASCII characters
#' @param string any character string
#' @return the string after dropping all html tags to spaces
#' @keywords internal
drop_nonascii <- function(string){
#  string <- gsub("\302\260", " degrees ", string)
#  string <- gsub("\342\200\223", " - ", string)  # <c2><96>
#  Other violating codes <c2><b0>, <c3><a9>, <c3><ad>, <c2><bd>, <c3><b3>
#  Faster solution to drop the offending codes:
   Encoding(string) <- "UTF-8"
#  string <- iconv(string, "UTF-8", "ASCII", "byte") # return hex code
   string <- iconv(string, "UTF-8", "ASCII", "") # just drop those chars
string
}

#' clean the fish.base data into pure ASCII
#' @param a list item with fishbase data
#' @return the item scrubbed of non-ASCII characters
#' @keywords internal
#' @examples \dontrun{
#'  data(fishbase)
#'  fish.data <- clean_data(fish.data)
#' }
clean_data <- function(fish.data){
  for(i in 1:length(fish.data)){
    for(j in 1:length(fish.data[[i]])){
      fish.data[[i]][[j]] <- drop_nonascii(fish.data[[i]][[j]])
    }
  }
  fish.data
}



