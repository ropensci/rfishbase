
## Allows us to define functions for each endpoint using closures
endpoint <- function(endpt, tidy_table = function(x) x){
  
  function(species_list, fields = NULL, limit = 200, server = SERVER, ...){
    codes <- speccodes(species_list)
    bind_rows(lapply(codes, function(code){ 
      args <- list(SpecCode = code,
                   limit = limit, 
                   fields = paste(fields, collapse=","))
      
      resp <- GET(paste0(server, "/", endpt), query = args, ..., user_agent(make_ua()))
      data <- check_and_parse(resp)
      
      tidy_table(data)
    }))
  }
}


## Function to create the user-agent string
make_ua <- function() {
  if(getOption("is_test", FALSE)){
    "automated_test"
  } else {
  versions <- c(rfishbase = as.character(packageVersion("rfishbase")),
                curl = RCurl::curlVersion()$version,
                Rcurl = as.character(packageVersion("RCurl")),
                httr = as.character(packageVersion("httr")))
  paste0(names(versions), "/", versions, collapse = " ")
  }
}
