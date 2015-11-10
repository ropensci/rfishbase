## Internal routine, used by most API calls

# @param resp an httr resp object
# @param debug should we return the httr response object for debugging
# if a call fails, or just NULL, (so that one a failed call does not break
# the execution of a long loop).
# @return the parsed data.frame, or NULL if checks fail to proceed
#' @importFrom httr warn_for_status content
#' @importFrom dplyr as_data_frame
check_and_parse <- function(resp, 
                            debug = getOption("debug", FALSE)){
  
  
  warn_for_status(resp)
  
  ## Parse the http response
  parsed <- content(resp)
  ## Check for errors or other issues
  proceed <- error_checks(parsed, resp = resp)
  
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
    
    if(debug)
      resp
    else
      NULL
  }
}

# error_checks
#
# check for parsing errors
# @param parsed the parsed JSON as a list
# @return logical, TRUE if all tests pass, FALSE otherwise
error_checks <- function(parsed, resp = structure(list(url="error, no httr response"), class="response")){
  proceed <- TRUE  
  
  # If API fails completely, parsed is just a character stream error:
  if(is.character(parsed)){ 
    warning(paste(parsed, "for query", resp$url))
    proceed <- FALSE
  } else if(!is.list(parsed) || length(parsed) == 0){
    warning(paste("Failed to parse or empty query results for", resp$url))
    proceed <- FALSE
  } else {
    ## check for errors in the API query
    if(!is.null(parsed$error)) {
        warning(paste(parsed$error, "for query", resp$url))
      proceed <- FALSE
    } else if(parsed$count == 0){
      warning(paste("No matches to query found","for query", resp$url))
      proceed <- FALSE
    } else if(parsed$count > parsed$returned){
      ## Comment if returns are incomplete.
      warning(paste("Returning first", parsed$returned, 
                    "matches parsed of", parsed$count, "matches.",
                    "\n Increase limit or refine query"))
      proceed <- TRUE
    }
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
    x <- strsplit(input, " ")[[1]]
    n <- length(x)
    
    if(n == 1 && !is.na(as.numeric(x))){
      list(speccode = as.integer(x))
    } else if(n >= 2) {
      list(genus = x[1], species = paste(x[2:n], collapse=" "))
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



