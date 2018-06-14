#' species_list
#' 
#' Return the a species list given a taxonomic group
#' @param Class Request all species in this taxonomic Class
#' @param Order Request all species in this taxonomic Order
#' @param Family Request all species in this taxonomic Family
#' @param SubFamily Request all species in this taxonomic SubFamily
#' @param Genus Request all species in this taxonomic Genus
#' @param Species Request all species in this taxonomic Species
#' @param SpecCode Request species name of species matching this SpecCode
#' @param server fishbase or 
#' @examples
#' \donttest{
#' ## All species in the Family 
#'   species_list(Family = 'Scaridae')
#' ## All species in the Genus 
#'   species_list(Genus = 'Labroides')
#' }
#' @export
species_list <- function(Class = NULL,
                         Order = NULL,
                         Family = NULL,
                         Subfamily = NULL,
                         Genus = NULL,
                         Species = NULL,
                         SpecCode = NULL,
                         SuperClass = NULL,
                         server = getOption("FISHBASE_API", FISHBASE_API)){
  ## This is a terribly designed function, since it's design is 
  ## ambiguous about how multiple non-null arguments should be treated!
  class <- enquo(Class)
  order <- enquo(Order)
  family <- enquo(Family)
  subfamiy <- enquo(Subfamily)
  genus <- enquo(Genus)
  species <- enquo(Species)
  superclass <- enquo(SuperClass)
  spec_code <- enquo(SpecCode)
  #if(!is.nullClass)
  taxa <- load_taxa() 
  if(!is.null(SuperClass)) taxa <- taxa %>% filter(SuperClass %in% !!superclass) 
  if(!is.null(Class)) taxa <- taxa %>% filter(Class %in% !!class) 
  if(!is.null(Order)) taxa <- taxa %>% filter(Order %in% !!order)
  if(!is.null(Family)) taxa <- taxa %>% filter(Family %in% !!family) 
  if(!is.null(Subfamily)) taxa <- taxa %>% filter(Subfamily %in% !!subfamily) 
  if(!is.null(Genus)) taxa <- taxa %>% filter(Genus %in% !!genus)
  if(!is.null(Species)) taxa <- taxa %>% filter(Species %in% !!species)
  if(!is.null(SpecCode)) taxa <- taxa %>% filter(SpecCode %in% !!spec_code)
  
  taxa$Species

}



# speccodes
#
# Returns SpecCodes given a list of species. Primarily for internal use
# 
# @examples
# who <- species_list(Family='Scaridae')
# speccodes(who)
speccodes <- function(species_list, db = fb_species()){ 
  
    if(is.integer(species_list))
      return(dplyr::data_frame(SpecCode = species_list))
    
    left_join(dplyr::data_frame(Species = species_list),
              db) %>%
      select(SpecCode)
  
  
}

