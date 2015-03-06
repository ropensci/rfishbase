endpoint <- function(endpt, ..., tidy_table = function(x) x){
  
  function(species_list, server = SERVER, limit = 100, fields = NULL, ...){
    codes <- speccodes(species_list)
    bind_rows(lapply(codes, function(code){ 
      args <- list(SpecCode = code,
                   limit = limit, 
                   fields = paste(fields, collapse=","))
      
      resp <- GET(paste0(server, "/", endpt), query = args)
      data <- check_and_parse(resp)
      
      tidy_table(data)
    }))
  }
}
