#' heartbeat
#' 
#' Check that the FishBase API server is responding
#' @inheritParams species
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
heartbeat <- function(server = getOption("FISHBASE_API", FISHBASE_API))
  GET(paste0(server, "/heartbeat"), user_agent(make_ua()))

#' ping
#' 
#' Check that the FishBase MySQL backend to the API is alos responding
#' @inheritParams species
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
ping <- function(server = getOption("FISHBASE_API", FISHBASE_API))
  GET(paste0(server, "/mysqlping"), user_agent(make_ua()))


