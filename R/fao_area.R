


codes <- species_table(species_list, fields="SpecCode")$SpecCode
do.call("rbind", lapply(codes, per_fao))

per_fao <- function(code, server = SERVER, verbose = TRUE, limit = 100){
  resp <- GET(paste0(server, "/faoareas"), query = list(SpecCode = code, limit = limit))
  
  data <- check_and_parse(resp, verbose = verbose)
  
  
  resp <- GET(paste0(server, "/faoarrefs"), query = list(SpecCode = code, limit = limit))
  
}