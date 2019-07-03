
#' load_taxa
#' 
#' @param server API for Fishbase or Sealifebase?
#' @param ... for compatibility with previous versions
#' @return the taxa list
#' @importFrom dplyr arrange
#' @export
load_taxa <- function(server = getOption("FISHBASE_API", "fishbase"), 
                      version = get_latest_release(),
                      db = default_db(),
                      ...){
  
  db_tbl <- tbl_name("taxa",  server, version)
  if(has_table(db_tbl)) return(dplyr::tbl(db, db_tbl))
  
  ## SeaLifeBase requires a different taxa table function:
  if(is.null(server)) server <- getOption("FISHBASE_API", FISHBASE_API)
  if(grepl("sealifebase", server)){
    slb_taxa_table(server, version, db)
  } else {
    fb_taxa_table(server, version, db)
  }
}
  



globalVariables(c("SpecCode", "Species", "Genus", "Subfamily", "Family", 
                  "Order", "Class", "SuperClass", "Phylum", "Kingdom", "tempcolumn"))


fb_taxa_table <- function(server = getOption("FISHBASE_API", "fishbase"),
                          version = get_latest_release(),
                          db = default_db()){
  
  taxon_species <- fb_tbl("species", server, version, db) %>% 
      select("SpecCode", "Species", "Genus", "Subfamily",
      "GenCode", "SubGenCode", "FamCode")
  
  taxon_genus <- fb_tbl("genera", server, version, db) %>%
    select("GenCode", "GenName", "GenusCommonName" = "GenComName", 
           "FamCode", "Subfamily", "SubgenusOf")
  
  taxon_family <- fb_tbl("families", server, version, db) %>% 
    select("FamCode", "Family","FamilyCommonName" = "CommonName", "Order",
           "Ordnum", "Class", "ClassNum")
  
  taxon_order <- fb_tbl("orders", server, version, db) %>%
    select("Ordnum", "Order", "OrderCommonName" = "CommonName",
           "ClassNum", "Class") 

  taxon_class <- fb_tbl("classes", server, version, db) %>% 
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
    dplyr::arrange(SpecCode) %>% 
    dplyr::mutate(Species = paste(Genus, Species)) %>%
    ## paste -> concat_ws fun, not implemented in Monet or duckdb now
    #dplyr::mutate(tempcolumn = concat(Genus, " ")) %>%
    #dplyr::mutate(Species = concat(tempcolumn, Species)) %>%
    #dplyr::select(-tempcolumn) %>%
    dplyr::compute(tbl_name("taxa", server, version), temporary=FALSE)
  
  taxa_table
}




slb_taxa_table <- function(server, version, db){
  
  server <- "sealifebase"
    
  taxon_species <- fb_tbl("species", server, version, db)
  taxon_genus <- fb_tbl("genera", server, version, db) 
  taxon_family <- fb_tbl("families", server, version, db)
  taxon_order <- fb_tbl("orders", server, version, db)
  taxon_class <- fb_tbl("classes", server, version, db)
  taxon_phylum <- fb_tbl("phylums", server, version, db)
  phylum_class <- fb_tbl("phylumclass", server, version, db) 
  
  
  keep <- names(taxon_species) %in% 
    c("SpecCode", "Species", "Genus",
      "GenCode", "SubGenCode", "FamCode")
  taxon_species <- taxon_species[keep]
  
  
  keep <- names(taxon_genus) %in% 
    c("GenCode", "GEN_NAME", "GenComName", "FamCode",
      "Subfamily", "SubgenusOf")
  taxon_genus <- taxon_genus[keep]
  i <- names(taxon_genus) == "GenComName"
  names(taxon_genus)[i] <- "GenusCommonName" 
  i <- names(taxon_genus) == "GEN_NAME"
  names(taxon_genus)[i] <- "Genus" 
  
  keep <- names(taxon_family) %in% 
    c("FamCode", "Family","CommonName", "Order",
      "Ordnum", "Class", "ClassNum")
  taxon_family <- taxon_family[keep]
  i <- names(taxon_family) == "CommonName"
  names(taxon_family)[i] <- "FamilyCommonName"
  
  keep <- names(taxon_order) %in% 
    c("Ordnum", "Order", "CommonName", "ClassNum", "Class") 
  taxon_order <- taxon_order[keep]
  i <- names(taxon_order) == "CommonName"
  names(taxon_order)[i] <- "OrderCommonName"
  
  keep <- names(taxon_class) %in% 
    c("ClassNum", "Class", "CommonName",
      "SuperClass", "Subclass")
  i <- names(taxon_class) == "CommonName"
  names(taxon_class)[i] <- "ClassCommonName"
  taxon_class <- taxon_class[keep]
  
  keep <- names(taxon_phylum) %in% 
    c("PhylumId", "Phylum", "Kingdom")
  i <- names(taxon_phylum) == "CommonName"
  names(taxon_phylum)[i] <- "PhylumCommonName"
  taxon_phylum <- taxon_phylum[keep]
  
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
    dplyr::select(SpecCode, Species, Genus, Subfamily, Family, 
                  Order, Class, Phylum, Kingdom) %>% 
    dplyr::arrange(SpecCode) %>% 
    dplyr::mutate(Species = paste(Genus, Species))
  
  taxa_table
}



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
