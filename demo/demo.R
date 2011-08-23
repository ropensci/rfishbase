# demo.R

require(rfishbase)

## a general function to loop over all fish ids to get data
getData <- function(fish.ids){
  suppressWarnings(
    lapply(fish.ids, function(i) try(fishbase(i)))
  )
}

# A function to extract the ages, handling missing values
get.ages <- function(fish.data){
              sapply(fish.data, function(out){
                 if(!(is(out,"try-error")))
                   x <- out$size_values[["age"]]
                 else
                   x <- NA
                 x
               })
  
}


# Process all the XML first, then extract the ages 
fish.data <- getData(2:500)
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



