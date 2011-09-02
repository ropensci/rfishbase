# downloadFishbase.R
rm(list=ls())
require(rfishbase)

## may be helpful to run chunks at different times if this errors
for(i in 1:14){
	M <- ceiling(70000/14)
	ids <- (1+(i-1)*M):(i*M)
	fish.data <- getData(ids, silent=FALSE)
	save(list="fish.data", file=paste("fishdata_", i, ".Rdat", sep=""))
	rm(list="fish.data") # clear some memory
}


###  Fuse and timestamp the collected chunks 
load("fishdata_1.Rdat")
all.fishbase <- fish.data 
for(i in 2:14){
	load(paste("fishdata_", i, ".Rdat", sep = ""))
	 all.fishbase <- c(fish.data, all.fishbase) 
}

print(length(all.fishbase))
save(list="all.fishbase", file=paste(Sys.Date(), "-fishbase", ".rda"), sep="")
