# demo.R
rm(list=ls())
require(rfishbase)
## Download and parse data for first 40 ids (36 fish)
#fish.data <- getData(1:40)

## Or just load the cached copy of the full fishbase data:
data(fishbase)
fish.data <- all.fishbase 

yr <- getSize(fish.data, "age")
hist(yr, breaks=40, main="Age Distribution", xlab="age (years)"); 
nfish <- length(fish.data)

labrid <- familySearch("Labridae", fish.data)
goby <- familySearch("Gobiidae", fish.data)

# get all those that are reefs 
labrid.reef <- habitatSearch("reef", fish.data[labrid])
# How many species are reef labrids:
sum(labrid.reef) #same as: length(fish.data[labrid][labrid.reef])

# How many reef gobies:
sum (habitatSearch("reef", fish.data[goby]) )

# Total number of freshwater species
sum(habitatSearch("freshwater", fish.data))

# Total number of marine species
sum( habitatSearch("marine", fish.data) )


