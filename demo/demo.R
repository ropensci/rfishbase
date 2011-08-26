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
fish.data <- getData(2:100)
yr <- get.ages(fish.data)

# Plot data
png("age.png"); 
hist(yr, breaks=40, main="Age Distribution", xlab="age (years)"); 
dev.off()


## Log in notebook for Reproducible Research 
require(socialR)
script <- "demo.R" # Must specify the script name! 
gitaddr <- gitcommit(script)     # Must commmit at start and store id.
upload("age.png", script=script, gitaddr=gitaddr)



