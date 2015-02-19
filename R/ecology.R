#' locations
#' 
#' return a table of species locations as reported in FishBASE.org FAO location data
#' 
#' @inheritParams species_info
#' @import dplyr
#' @export
#' @examples
#' \dontrun {
#' fish <- species_list(Genus='Labroides')
#' ecology(fish)
#' }
ecology <- endpoint("ecology") 


fooditems <- endpoint("fooditems")
oxygen <- endpoint("oxygen")

popchar <- endpoint("popchar")
popgrowth <- endpoint("popgrowth")
length_freq <- endpoint("poplf")
length_length <- endpoint("popll")
length_weight <- endpoint("poplw")


endpoint <- function(endpoint, tidy_table = function(x) x)
  function(species_list, server = SERVER, limit = 100, fields = NULL){
  
  bind_rows(lapply(species_list, function(species){ 
  
    s <- parse_name(species)

    args <- list(species = s$species, genus = s$genus, SpecCode = s$speccode,
                 limit = limit, fields = paste(fields, collapse=","))
                 
    resp <- GET(paste0(server, "/ecology"), query = args)
    data <- check_and_parse(resp)
    
  #  tidy_ecology_table(data)
  data 
    }))

}





