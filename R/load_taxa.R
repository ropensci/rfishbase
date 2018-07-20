
#' load_taxa
#' 
#' @param server API for Fishbase or Sealifebase?
#' @param ... for compatibility with previous versions
#' @return the taxa list
#' @importFrom dplyr arrange
#' @export
load_taxa <- memoise::memoise(function(server = NULL, ...){

  
  taxon_species <- fb_tbl("species", server)
  keep <- names(taxon_species) %in% c("SpecCode", "Species", "Genus", "Subfamily",
                                      "GenCode", "SubGenCode", "FamCode")
  taxon_species <- taxon_species[keep]
  
  taxon_genus <- fb_tbl("genera", server) 
  keep <- names(taxon_genus) %in% c("GenCode", "GenName", "GenComName", "FamCode",
                                    "Subfamily", "SubgenusOf")
  taxon_genus <- taxon_genus[keep]
  i <- names(taxon_genus) == "GenComName"
  names(taxon_genus)[i] <- "GenusCommonName" 
  
  taxon_family <- fb_tbl("families", server) %>% 
    select(FamCode, Family, FamilyCommonName = CommonName, Order, Ordnum, Class, ClassNum) 
  
  taxon_order <- fb_tbl("orders", server) %>% select(Ordnum, Order, OrderCommonName = CommonName, ClassNum, Class) 
  
  
  taxon_class <- fb_tbl("classes", server)
  keep <- names(taxon_class) %in% c("ClassNum", "Class", "CommonName",
           "SuperClass", "Subclass")
  i <- names(taxon_class) == "CommonName"
  names(taxon_class)[i] <- "ClassCommonName"
  taxon_class <- taxon_class[keep]

  
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
globalVariables(c("SpecCode", "Species", "Genus", "Subfamily", "Family", 
        "Order", "Class", "SuperClass"))
        
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
