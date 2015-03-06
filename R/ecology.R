#' ecology
#' 
#' return a table of species ecology
#' 
#' @inheritParams species_info
#' @import dplyr
#' @export
#' @examples
#' \dontrun{
#' ecology("Oreochromis niloticus")
#' 
#' ## trophic levels and standard errors for a list of species
#' ecology(c("Oreochromis niloticus", "Salmo trutta"),
#'         fields=c("SpecCode", "FoodTroph", "FoodSeTroph", "DietTroph", "DietSeTroph"))
#' }
ecology <- function(species_list, limit = 1, server = SERVER) 
  ecology_endpoint(species_list, limit = limit, server = server)

## This function wants to have custom default for the 'limit' argument.  To do this, first create 
## a function with the generic default using endpoint(), and then use it to define a new function.
## For some reason, `ecology` table often returns additional results with different stockcodes but no
## new data for the species in question.  Should be investigated further.  
ecology_endpoint <- endpoint("ecology") 




fooditems <- endpoint("fooditems")
oxygen <- endpoint("oxygen")

popchar <- endpoint("popchar")
popgrowth <- endpoint("popgrowth")
length_freq <- endpoint("poplf")
length_length <- endpoint("popll")
length_weight <- endpoint("poplw")

