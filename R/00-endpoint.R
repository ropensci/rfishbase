
## Allows us to define functions for each endpoint using closures
#' @importFrom httr GET
#' @importFrom dplyr bind_rows
endpoint <- function(endpt, tidy_table = default_tidy){
  
  function(species_list=NULL, fields = NULL, limit = 200, server = getOption("FISHBASE_API", FISHBASE_API), ...){
    
    codes <- speccodes(species_list)
    if(is.list(codes) && length(codes)>0) {# partial match
      warning(paste(length(codes[lapply(codes, length)>1]),'of the supplied species names match species in fishbase: \n'),paste(species_list[unlist(lapply(codes, length)>1)], collapse = '\n')) 
      codes <- codes[lapply(codes, length)==1]
    } else if(is.matrix(codes)) { # no match
      stop('None of the supplied species names match species in fishbase') 
    } else if (length(codes) == 0) { # return table up to limit
      codes = ''
      warning('No species list supplied: retrieving data up to limit')
    }
    
    dplyr::bind_rows(lapply(codes, function(code){
      
      # only do this if no species supplied
      if(nchar(code)==0 && limit>5000){
        k <- 0
        data <- {}
        while(k<limit){
          
          args <- list(SpecCode = code,
                       limit = as.integer(min(5000,limit-k)), 
                       offset=as.integer(k+1))
          if(!is.null(fields)) 
            args <- c(args, 
                      fields = paste(c("SpecCode", fields), 
                                     collapse=","))
          
          # Workaround for inconsistent names in certain endpoints
          bad_tables = c('diet', 'ecosystem', 'maturity', 'morphdat', 'morphmet', 'popchar', 'poplf')
          if(endpt %in% bad_tables){
            names(args)[names(args) == "SpecCode"] = "Speccode"
          }
          
          resp <- httr::GET(paste0(server, "/", endpt), 
                            query = args, 
                            ..., 
                            httr::user_agent(make_ua()))
          tmp_data <- check_and_parse(resp)
          k <- k+5000
          data <- rbind(data,tmp_data)          
        }
      } else {
        
        args <- list(SpecCode = code,
                     limit = limit)
        if(!is.null(fields)) 
          args <- c(args, 
                    fields = paste(c("SpecCode", fields), 
                                   collapse=","))
        
        # Workaround for inconsistent names in certain endpoints
        bad_tables = c('diet', 'ecosystem', 'maturity', 'morphdat', 'morphmet', 'popchar', 'poplf')
        if(endpt %in% bad_tables){
          names(args)[names(args) == "SpecCode"] = "Speccode"
        }
        
        resp <- httr::GET(paste0(server, "/", endpt), 
                          query = args, 
                          ..., 
                          httr::user_agent(make_ua()))
        data <- check_and_parse(resp)
        
      }
      
      # this fails if returned data is NULL
      if(endpt %in% bad_tables && !is.null(data)){
        names(data)[names(data) == "Speccode"] = "SpecCode"
      }
      
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
