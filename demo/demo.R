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







# Now let's just grab the entire fishbase database, 
#fish.data <- getData(1:30000)


habitatSearch <- function(keyword, fish.data){
# A function to search for the occurances of a keyword in habitat description
# Args:
#   keyword: pattern to be used by grep
#   fish.data: list of outputs from fishbase(), or from getData()
# Example:
#   data <- getData(1:10)
#   habitatSearch("feshwater", data)
  x <- sapply(fish.data, function(x) grep(keyword, x$habitat) )
  x <- as.integer(x)
}


x <- habitatSearch("reef", fish.data)
reef <- sum(x, na.rm=T)
nonreef <- sum(is.na(x))
percent_reef <- reef/(reef+nonreef) 



## Log in lab notebook for Reproducible Research 
require(socialR)
script <- "demo.R" # Must specify the script name! 
gitaddr <- gitcommit(script)     # Must commmit at start and store id.
#upload("age.png", script=script, gitaddr=gitaddr)



