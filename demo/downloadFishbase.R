# demo.R
rm(list=ls())
require(rfishbase)
require(socialR)
tweet("Downloading fishbase ids 20,000 : 30,000")

# Now let's just grab the entire fishbase database, 
fish.dataC <- getData(30001:40000)
tweet(paste("D: Done downloading ", length(fish.dataC), "entries"))
save(list="fish.dataD", file="fishD.Rdat")
rm(list=ls())

fish.dataC <- getData(20001:30000)
tweet(paste("C: Done downloading ", length(fish.dataC), "entries"))
save(list="fish.dataC", file="fishC.Rdat")
rm(list=ls())

fish.dataB <- getData(10001:20000)
tweet(paste("B: Done downloading ", length(fish.dataB), "entries"))
save(list="fish.dataB", file="fishB.Rdat")
rm(list=ls())


fish.dataB <- getData(1:10000)
tweet(paste("A: Done downloading ", length(fish.dataA), "entries"))
save(list="fish.dataA", file="fishA.Rdat")


