# Check that server is responding

heartbeat <- function(server = SERVER)
  GET(paste0(server, "/heartbeat"))

ping <- function(server = SERVER)
  GET(paste0(server, "/mysqlping"))

# Consider echoing resp$times[["total"]] for time in seconds
# Full resp info has useful debugging record. 
