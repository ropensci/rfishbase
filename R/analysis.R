habitatSearch <- function(keyword, fish.data){
# A function to search for the occurances of any keyword in habitat description
# Args:
#   keyword: pattern to be used by grep
#   fish.data: list of outputs from fishbase(), or from getData()
# Example:
#   data <- getData(1:10)
#   habitatSearch("feshwater", data)
  x <- sapply(fish.data, function(x) grep(keyword, x$habitat) )
  x <- as.integer(x) # clean up data 
  x[is.na(x)] <- 0   # cean up data
  x
}

familySearch <- function(family, fish.data){
  x <- sapply(fish.data, function(x) x$Family==family)
}


getSize <- function(fish.data, value=c("length", "weight", "age")){
# A function to extract 
  match.arg(value)
  y <- sapply(fish.data, function(x) x$size_values[[value]])
  unlist(y)
}


