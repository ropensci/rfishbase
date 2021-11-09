
#' reproduction
#' 
#' @return a table of species reproduction
#' @inheritParams species
#' @export
#' @examplesIf interactive()
#'  \dontrun{
#' reproduction("Oreochromis niloticus")
#' }
reproduction <- endpoint("reproduc")


#' fecundity
#' 
#' @return a table of species fecundity
#' @inheritParams species
#' @export
#' @examplesIf interactive()
#'  \dontrun{
#' fecundity("Oreochromis niloticus")
#' }
fecundity <- endpoint("fecundity")


#' maturity
#' 
#' @return a table of species maturity
#' @inheritParams species
#' @export
#' @examplesIf interactive()
#'  \dontrun{
#' maturity("Oreochromis niloticus")
#' }
maturity <- endpoint("maturity")


#' spawning
#' 
#' @return a table of species spawning
#' @inheritParams species
#' @export
#' @examplesIf interactive()
#'  \dontrun{
#' spawning("Oreochromis niloticus")
#' }
spawning <- endpoint("spawning")

#' larvae
#' 
#' @return a table of larval data
#' @inheritParams species
#' @export
#' @examplesIf interactive()
#'  \dontrun{
#' larvae("Oreochromis niloticus")
#' }
larvae <- endpoint("larvae")
