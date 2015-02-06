
# FIXME at the moment the server requires as genus or species name, and will return the matching taxonomy

#' @examples
#' taxa(list(family = 'Scaridae'))
#' taxa(list(genus='Labroides'))
taxa <- function(query, limit = 100, verbose = TRUE){
  
  query <- c(query, limit=limit)
  resp <- GET(paste0(server, "/taxa"), query = query)
 
  stop_for_status(resp)
  
  parsed <- content(resp)
  
  error_checks(parsed, verbose = verbose)
    
  data <- parsed$data
  
  L <- lapply(data, null_to_NA)
  df <- do.call(rbind.data.frame, L)
  
  sapply(data, function(x) sprintf("%s %s", x$Genus, x$Species))
}