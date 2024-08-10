

load_taxa_ <- function(server = c("fishbase", "sealifebase"), 
                      version = "latest",
                      ...){
  server <- match.arg(server)
  ## SeaLifeBase requires a different taxa table function:
  if(grepl("sealifebase", server)){
    taxa_table <- slb_taxa_table(version)
  } else {
    taxa_table <- fb_taxa_table(version)
  }
  
  taxa_table
}

#' load_taxa
#' 
#' @param server Either "fishbase" (the default) or "sealifebase"
#' @param version the version of the database you want. Will default to the
#' latest available; see [available_releases()].
#' @param ... for compatibility with previous versions
#' @return the taxa list
#' @export
load_taxa <- memoise::memoise(load_taxa_)



dummy_fn <- function(f) {
  # CRAN check doesn't recognize memoise use in the above and throws note:
  # Namespace in Imports field not imported from: ‘memoise’
  memoise::memoise(f)
}



globalVariables(c("SpecCode", "Species", "Genus", "Subfamily", "Family", 
                  "Order", "Class", "SuperClass", "Phylum", "Kingdom", "tempcolumn"))


fb_taxa_table <- function(version = "latest", db = NULL){
    
  server <- "fishbase"
  
  taxon_species <- fb_tbl("species", server, version, db, collect=FALSE) %>% 
      select("SpecCode", "Species", "Genus", "Subfamily",
             "GenCode", "SubGenCode", "FamCode")
  
  taxon_genus <- fb_tbl("genera", server, version, db, collect=FALSE) %>%
    select("GenCode", "GenName", "GenusCommonName" = "GenComName", 
           "FamCode", "Subfamily", "SubgenusOf")
  
  taxon_family <- fb_tbl("families", server, version, db, collect=FALSE) %>% 
    select("FamCode", "Family","FamilyCommonName" = "CommonName", "Order",
           "Ordnum", "Class", "ClassNum")
  
  taxon_order <- fb_tbl("orders", server, version, db, collect=FALSE) %>%
    select("Ordnum", "Order", "OrderCommonName" = "CommonName",
           "ClassNum", "Class") 

  taxon_class <- fb_tbl("classes", server, version, db, collect=FALSE) %>% 
    select("ClassNum", "Class", "ClassCommonName" = "CommonName",
           "SuperClass", "Subclass")
  
  taxon_hierarchy <- 
    taxon_species %>%
    left_join(taxon_genus) %>%
    left_join(taxon_family )%>%
    left_join(taxon_order) %>%
    left_join(taxon_class)
  
  taxa_table <- 
    taxon_hierarchy %>% 
    dplyr::select("SpecCode", "Species", "Genus", "Subfamily", "Family", 
           "Order", "Class", "SuperClass") %>% 
    dplyr::mutate(Species = paste(Genus, Species)) %>%
    dplyr::collect()
  taxa_table
  

}




slb_taxa_table <- function(version = "latest", db=NULL){
  
  server <- "sealifebase"
    
  taxon_species <- fb_tbl("species", server, version, db) %>%
    select("SpecCode", "Species", "Genus",
           "GenCode", "SubGenCode", "FamCode")
  taxon_genus <- fb_tbl("genera", server, version, db) %>% 
    select("GenCode", "Genus" = "GEN_NAME",
           "GenusCommonName" = "CommonName", "FamCode" = "Famcode",
           "Subfamily")
  taxon_family <- fb_tbl("families", server, version, db) %>% 
    select("FamCode", "Family","FamilyCommonName"="CommonName", "Order",
            "Ordnum", "Class", "ClassNum")
  taxon_order <- fb_tbl("orders", server, version, db) %>% 
    select("Ordnum", "Order", "OrderCommonName"= "CommonName", "ClassNum", "Class") 
  taxon_class <- fb_tbl("classes", server, version, db) %>% 
    select("ClassNum", "Class", "ClassCommonName" = "CommonName")
  taxon_phylum <- fb_tbl("phylums", server, version, db) %>% 
    select("PhylumId", "Phylum", "Kingdom", "PhylumCommonName" = "CommonName")
  phylum_class <- fb_tbl("phylumclass", server, version, db) 
  
  suppressMessages(
    taxon_hierarchy <- 
      taxon_species %>%
      left_join(taxon_genus) %>%
      left_join(taxon_family )%>%
      left_join(taxon_order) %>%
      left_join(taxon_class) %>%
      left_join(phylum_class) %>%
      left_join(taxon_phylum)
  )
  
  taxa_table <- 
    taxon_hierarchy %>% 
    dplyr::select("SpecCode", "Species", "Genus", "Subfamily", "Family", 
                  "Order", "Class", "Phylum", "Kingdom") %>% 
    dplyr::mutate(Species = paste(Genus, Species)) #%>%
    #dplyr::arrange("SpecCode")
    
  taxa_table
}



#' A table of all the the species found in FishBase, including taxonomic
#' classification and the Species Code (SpecCode) by which the species is
#' identified in FishBase.
#'
#' @name fishbase
#' @docType data
#' @author Carl Boettiger \email{carl@@ropensci.org}
#' @keywords data
NULL


#' A table of all the the species found in SeaLifeBase, including taxonomic
#' classification and the Species Code (SpecCode) by which the species is
#' identified in SeaLifeBase
#'
#' @name sealifebase
#' @docType data
#' @author Carl Boettiger \email{carl@@ropensci.org}
#' @keywords data
NULL


## Code to update the package cache:
# fishbase <- load_taxa(update = TRUE, limit = 35000)
# sealifebase <- load_taxa(update=TRUE, server = "https://fishbase.ropensci.org/sealifebase", limit = 120000)
# save("fishbase", file = "data/fishbase.rda", compress = "xz")
# save("sealifebase", file = "data/sealifebase.rda", compress = "xz")
