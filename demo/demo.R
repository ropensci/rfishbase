require(fishbase)

require(socialR)
script <- "demo.R" # Must specify the script name! 
gitaddr <- gitcommit(script)     # Must commmit at start and store id.



weights(2:500)->a

png("weights.png"); 
hist(log(a), breaks=40, main="Weight Distribution", xlab="Log mass (g)"); 
dev.off()
upload("weights.png", script=script, gitaddr=gitaddr)
