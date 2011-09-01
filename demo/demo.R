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






require(socialR)
tweet("Downloading fishbase ids 20,000 : 30,000")
# Now let's just grab the entire fishbase database, 
fish.dataC <- getData(20001:30000)
tweet(paste("Done downloading ", length(fish.dataC), "entries"))
fish.dataB <- getData(10001:20000)
tweet(paste("Done downloading ", length(fish.dataB), "entries"))
fish.dataA <- getData(1:10000)
tweet(paste("Done downloading ", length(fish.dataA), "entries"))

fish.data <- c(fish.dataA, fish.dataB, fish.dataC)

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

save(list=ls(), file="fishbase.Rdat")

## Log in lab notebook for Reproducible Research 
require(socialR)
script <- "demo.R" # Must specify the script name! 
gitaddr <- gitcommit(script)     # Must commmit at start and store id.
#upload("age.png", script=script, gitaddr=gitaddr)



