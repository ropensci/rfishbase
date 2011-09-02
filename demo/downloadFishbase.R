# demo.R
rm(list=ls())
require(rfishbase)
# may be helpful to run chunks at different times
for(i in 1:14){
	M <- ceiling(70000/14)
	ids <- (1+(i-1)*M):(i*M)
	fish.data <- getData(ids, silent=FALSE)
	save(list="fish.data", file=paste("fishdata_", i, ".Rdat", sep=""))
	rm(list="fish.data")
}

