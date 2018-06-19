

FISHBASE_API <- "https://fishbase.ropensci.org"
SEALIFEBASE_API <- "https://fishbase.ropensci.org/sealifebase"

#' load_taxa
#' 
#' @param server API for Fishbase or Sealifebase?
#' @param ... for compatibility with previous versions
#' @return the taxa list
#' @importFrom dplyr arrange
#' @export
load_taxa <- memoise::memoise(function(server = getOption("FISHBASE_API", FISHBASE_API), ...){

  taxon_species <- fb_tbl("species") %>% 
    select(SpecCode, Species, Genus, Subfamily, GenCode, SubGenCode, FamCode)
  taxon_genus <- fb_tbl("genera") %>% 
    select(GenCode, GenName, GenusCommonName = GenComName, FamCode, Subfamily,
           SubgenusOf)
  taxon_family <- fb_tbl("families") %>% 
    select(FamCode, Family, FamilyCommonName = CommonName, Order, 
           Ordnum, Class, ClassNum) 
  taxon_order <- fb_tbl("orders") %>% 
    select(Ordnum, Order, OrderCommonName = CommonName, ClassNum, Class) 
  taxon_class <- fb_tbl("classes") %>% 
    select(ClassNum, Class, ClassCommonName = CommonName,
           SuperClass, Subclass)

  
  suppressMessages(
  taxon_hierarchy <- 
    taxon_species %>%
    left_join(taxon_genus) %>%
    left_join(taxon_family )%>%
    left_join(taxon_order) %>%
    left_join(taxon_class)
  )
  
  taxa_table <- 
    taxon_hierarchy %>% 
    dplyr::select(SpecCode, Species, Genus, Subfamily, Family, 
           Order, Class, SuperClass) %>% 
    dplyr::arrange(SpecCode) %>% 
    dplyr::mutate(Species = paste(Genus, Species))
  
  taxa_table
})

#' A table of all the the species found in FishBase, including taxonomic
#' classification and the Species Code (SpecCode) by which the species is
#' identified in FishBase.
#'
#' @name fishbase
#' @docType data
#' @author Carl Boettiger \email{carl@@ropensci.org}
#' @references \url{FishBase.org}
#' @keywords data
NULL


#' A table of all the the species found in SeaLifeBase, including taxonomic
#' classification and the Species Code (SpecCode) by which the species is
#' identified in SeaLifeBase
#'
#' @name sealifebase
#' @docType data
#' @author Carl Boettiger \email{carl@@ropensci.org}
#' @references \url{www.sealifebase.org}
#' @keywords data
NULL


## Code to update the package cache:
# fishbase <- load_taxa(update = TRUE, limit = 35000)
# sealifebase <- load_taxa(update=TRUE, server = "https://fishbase.ropensci.org/sealifebase", limit = 120000)
# save("fishbase", file = "data/fishbase.rda", compress = "xz")
# save("sealifebase", file = "data/sealifebase.rda", compress = "xz")
