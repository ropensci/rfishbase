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
#' @importFrom httr GET user_agent
#' @export
heartbeat <- function(server = getOption("FISHBASE_API", FISHBASE_API))
  httr::GET(paste0(server, "/heartbeat"), httr::user_agent(make_ua()))

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
#' @importFrom httr GET user_agent
#' @export
ping <- function(server = getOption("FISHBASE_API", FISHBASE_API))
  GET(paste0(server, "/mysqlping"), user_agent(make_ua()))


