# demo.R
rm(list=ls())
require(rfishbase)
fish.data <- getData(1:70000, silent=FALSE)
save(list="fish.data", file=paste(SysDate(), "fishdata.Rdat", sep=""))


