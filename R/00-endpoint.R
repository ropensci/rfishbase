
## Allows us to define functions for each endpoint using closures
#' @importFrom httr GET
#' @importFrom dplyr bind_rows
endpoint <- function(endpt, tidy_table = default_tidy){
  
  function(species_list, fields = NULL, limit = 200, server = getOption("FISHBASE_API", FISHBASE_API), ...){
    codes <- speccodes(species_list)
    dplyr::bind_rows(lapply(codes, function(code){
      args <- list(SpecCode = code,
                   limit = limit)
      if(!is.null(fields)) 
        args <- c(args, 
                  fields = paste(c("SpecCode", fields), 
                                 collapse=","))
       
      
      resp <- httr::GET(paste0(server, "/", endpt), 
                        query = args, 
                        ..., 
                        httr::user_agent(make_ua()))
      data <- check_and_parse(resp)
      
      tidy_table(data, server = server)
    }))
  }
}


default_tidy <- function(x, server = getOption("FISHBASE_API", FISHBASE_API)){
  if("SpecCode" %in% names(x)){
    code <- x$SpecCode
    x$SpecCode <- species_names(code, server = server)
    names(x)[names(x) == "SpecCode"] <- "sciname"
    x <- cbind(x, SpecCode = code)
  }
  x

}






## Function to create the user-agent string
make_ua <- function() {
  if(getOption("is_test", FALSE)){
    "automated_test"
  } else {
  versions <- c(rfishbase = as.character(packageVersion("rfishbase")),
                httr = as.character(packageVersion("httr")))
  paste0(names(versions), "/", versions, collapse = " ")
  }
}
