#' ecology
#' 
#' @return a table of species ecology data
#' @details By default, will only return one entry (row) per species.  Increase limit to
#' get multiple returns for different stocks of the same species, though often data is either
#' identical to the first or simply missing in the additional stocks. 
#' @inheritParams species_info
#' @import dplyr
#' @export
#' @examples
#' \donttest{
#' ecology("Oreochromis niloticus")
#' 
#' ## trophic levels and standard errors for a list of species
#' ecology(c("Oreochromis niloticus", "Salmo trutta"),
#'         fields=c("SpecCode", "FoodTroph", "FoodSeTroph", "DietTroph", "DietSeTroph"))
#' }
ecology <- function(species_list, fields = NULL, limit = 1, server = SERVER){
  if(limit == 1) # don't bug user about missing returns
    suppressWarnings(ecology_endpoint(species_list, fields = fields, limit = limit, server = server))
  else
    ecology_endpoint(species_list, fields = fields, limit = limit, server = server)
}

## This function wants to have custom default for the 'limit' argument.  To do this, first create 
## a function with the generic default using endpoint(), and then use it to define a new function.
## For some reason, `ecology` table often returns additional results with different stockcodes but no
## new data for the species in question.  Should be investigated further.  
ecology_endpoint <- endpoint("ecology") 
