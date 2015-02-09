#' heartbeat
#' 
#' Check that the FishBase API server is responding
#' @inheritParams species_info
#' @return An httr 'response' object.
#' @examples
#' \dontrun{
#' 
#' ## Show server response times
#' resp <- heartbeat()
#' resp$times
#' 
#' ## Show API endpoints:
#' content(resp)
#' 
#' }
#' @import httr
#' @export
heartbeat <- function(server = SERVER)
  GET(paste0(server, "/heartbeat"))

#' ping
#' 
#' Check that the FishBase MySQL backend to the API is alos responding
#' @inheritParams species_info
#' @return An httr 'response' object.
#' @examples
#' \dontrun{
#' 
#' ## Show server response times
#' resp <- ping()
#' resp$times
#' 
#' }
#' @import httr
#' @export
ping <- function(server = SERVER)
  GET(paste0(server, "/mysqlping"))


