# demo.R

require(rfishbase)
require(socialR)
script <- "demo.R" # Must specify the script name! 
gitaddr <- gitcommit(script)     # Must commmit at start and store id.


getData <- function(fish.ids){
  suppressWarnings(
    lapply(fish.ids, function(i) try(fishbase(i)))
  )
}

fish.data <- getData(2:500)
get.ages <- function(fish.data){
              sapply(fish.data, function(out){
                 if(!(is(out,"try-error")))
                   x <- out$size_values[["age"]]
                 else
                   x <- NA
                 x
               })
  
}

yr <- get.ages(fish.data)
png("age.png"); 
hist(yr, breaks=40, main="Age Distribution", xlab="age (years)"); 
dev.off()
upload("age.png", script=script, gitaddr=gitaddr)



