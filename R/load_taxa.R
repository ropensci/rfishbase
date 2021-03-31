
#' load_taxa
#' 
#' @param server Either "fishbase" (the default) or "sealifebase"
#' @param version the version of the database you want. Will default to the
#' latest avialable; see [available_releases()].
#' @param db A remote database connection. Will default to the best available
#' system, see [default_db()].
#' @param ... for compatibility with previous versions
#' @return the taxa list
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
    dplyr::mutate(Species = paste(Genus, Species)) %>%
    ## paste -> concat_ws fun, not implemented in Monet or duckdb now
    #dplyr::mutate(tempcolumn = concat(Genus, " ")) %>%
    #dplyr::mutate(Species = concat(tempcolumn, Species)) %>%
    #dplyr::select(-tempcolumn) %>%
    #dplyr::arrange(SpecCode) %>% 
    dplyr::compute(tbl_name("taxa", server, version), temporary=FALSE)
  
  taxa_table
}




slb_taxa_table <- function(server, version, db){
  
  server <- "sealifebase"
    
  taxon_species <- fb_tbl("species", server, version, db) %>%
    select("SpecCode", "Species", "Genus",
           "GenCode", "SubGenCode", "FamCode")
  taxon_genus <- fb_tbl("genera", server, version, db) %>% 
    select("GenCode", "Genus" = "GEN_NAME", "GenusCommonName" = "CommonName", "FamCode" = "Famcode",
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
