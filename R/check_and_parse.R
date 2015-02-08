## Internal routine, used by most API calls

# @param resp an httr resp object
# @param verbose logical, indates if we give explicit warnings
# @return the parsed data.frame, or NULL if checks fail to proceed
check_and_parse <- function(resp, verbose = TRUE){
  
  
  stop_for_status(resp)
  
  ## Parse the http response
  parsed <- content(resp)
  ## Check for errors or other issues
  proceed <- error_checks(parsed, verbose = verbose)
  
  if(proceed) {
    ## Collapse to data.frame. ARG!! CANNOT ESCAPE THE do.call :`-( 
    ## ARG must manually do null to NA
    options(stringsAsFactors = FALSE)
    df <- as_data_frame(do.call(rbind.data.frame, 
                                lapply(parsed$data, null_to_NA)))
    df[df == 'NA'] <- NA
    df    
    # combine(parsed$data)  # FAIL!!
    # bind_rows(lapply(parsed$data, null_to_NA))  # FAIL!!
  } else {
    
    NULL
    
  }
}

# error_checks
#
# check for parsing errors
# @param parsed the parsed JSON as a list
# @return logical, TRUE if all tests pass, FALSE otherwise
error_checks <- function(parsed, verbose = TRUE){
  proceed <- TRUE  
  ## check for errors in the API query
  if(!is.null(parsed$error)) {
    if(verbose) stop(parsed$error)
    proceed <- FALSE
  }
  ## Comment if returns are incomplete.
  if(parsed$count > parsed$returned){
    if(verbose) warning(paste("Retruning first", parsed$returned, 
                              "matches parsed of", parsed$count, "matches.",
                              "\n Increase limit or refine query"))
    proceed <- TRUE
  }
  if(parsed$count == 0){
    warning("No matches to query found")
    proceed <- FALSE
  }
  proceed
}


# simple helper function
# Goodnes gracious I wish dplyr::bind_rows would handle this case!
null_to_NA <- function(x) {
  x[sapply(x, is.null)] <- NA
  return(x)
}



# parse scientific name.   
# Assume value is a speccode if it is either a numeric or a scientific na
parse_name <- function(input){
  
  if(is.character(input)){
    x <- str_split(input, " ")[[1]]
    
    if(length(x) == 1 && !is.na(as.numeric(x))){
      list(speccode = as.integer(x))
    } else if(length(x) >= 2) {
      list(genus = x[1], species = x[2])
    } else { 
      warning(paste("Species ", input, "could not be parsed"))
      list(NULL)
    }
    
  } else if(is.numeric(input)) {
    list(speccode=as.integer(input))
    
  } else { 
    warning(paste("Species ", input, "could not be parsed"))
    list(NULL)
  }
  
}



