# cacheFB.R

updateCache <- function(){
  date=Sys.Date()
  file=paste(date, "fishdata.Rdat", sep="")
  fish.data <- getData(1:70000, silent=FALSE)
  save(list="fish.data", file=file)
}

loadCache <- function(date=Sys.Date()){
  # load a file from the cache
  file=paste(date, "fishdata.Rdat", sep="")
  load(file)
}


