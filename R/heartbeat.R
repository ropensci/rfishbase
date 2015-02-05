# Check that server is responding

heartbeat <- function(server = SERVER)
  GET(paste0(server, "/heartbeat"))
