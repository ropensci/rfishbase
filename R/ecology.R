#' ecology
#' 
#' return a table of species ecology as reported in FishBASE.org FAO location data
#' 
#' @inheritParams species_info
#' @import dplyr
#' @export
#' @examples
#' \dontrun{
#' #' ecology("Oreochromis niloticus")
#' }
ecology <- endpoint("ecology") 





fooditems <- endpoint("fooditems")
oxygen <- endpoint("oxygen")

popchar <- endpoint("popchar")
popgrowth <- endpoint("popgrowth")
length_freq <- endpoint("poplf")
length_length <- endpoint("popll")
length_weight <- endpoint("poplw")

