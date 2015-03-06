# Morphology and Physiology tables, http://www.fishbase.org/manual/english/fishbasemorphology_and_physiology.htm


#' oxygen
#' 
#' @return a table of species oxygen data
#' @inheritParams species_info
#' @export
#' @examples \donttest{
#' oxygen("Oreochromis niloticus")
#' }
oxygen <- endpoint("oxygen")

#' morphology
#' 
#' @return a table of species morphology data
#' @inheritParams species_info
#' @export
#' @examples \donttest{
#' morphology("Oreochromis niloticus")
#' }
morphology <- endpoint("morphdat")

#' morphometrics
#' 
#' @return a table of species morphometrics data
#' @inheritParams species_info
#' @export
#' @examples \donttest{
#' morphometrics("Oreochromis niloticus")
#' }
morphometrics <- endpoint("morphmet")

#' swimming
#' 
#' @return a table of species swimming data
#' @inheritParams species_info
#' @export
#' @examples \donttest{
#' swimming("Oreochromis niloticus")
#' }
swimming <- endpoint("swimming")

#' speed
#' 
#' @return a table of species speed data
#' @inheritParams species_info
#' @export
#' @examples \donttest{
#' speed("Oreochromis niloticus")
#' }
speed <- endpoint("speed")