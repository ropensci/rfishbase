# demo.R
require(rfishbase)
# A function to extract the ages, handling missing values
get.ages <- function(fish.data){
              x <- sapply(fish.data, 
                     function(out){
                       out$size_values[["age"]]
               })
              unlist(x)
}


# Process all the XML first, then extract the ages 
fish.data <- getData(2:40)
yr <- get.ages(fish.data)

# Plot data
png("age.png"); 
hist(yr, breaks=40, main="Age Distribution", xlab="age (years)"); 
dev.off()

habitatSearch <- function(keyword, fish.data){
# A function to search for the occurances of any keyword in habitat description
# Args:
#   keyword: pattern to be used by grep
#   fish.data: list of outputs from fishbase(), or from getData()
# Example:
#   data <- getData(1:10)
#   habitatSearch("feshwater", data)
  x <- sapply(fish.data, function(x) grep(keyword, x$habitat) )
  x <- as.integer(x)
}

is.fresh <- habitatSearch("freshwater", fish.data)
freshwater <- sum(is.fresh, na.rm=T)
is.marine <- habitatSearch("marine", fish.data)
freshwater <- sum(is.marine, na.rm=T)




