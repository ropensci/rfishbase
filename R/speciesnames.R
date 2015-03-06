#' speciesnames
#' 
#' returns species names given FishBase's SpecCodes
#' 
#' @param codes a vector of speccodes (e.g. column from a table)
#' @param all_taxa the taxa table, usually loaded by default
#' @return A character vector of species names for the SpecCodes
#' @import dplyr
#' @export 
speciesnames <- function(codes, all_taxa = load_taxa()){
  sapply(codes, function(x){ 
    df <- taxa(list(SpecCode = x), all_taxa = all_taxa)
    sci_names <- select_(df, "Genus", "Species")
    unite_(sci_names, "sci", c("Genus", "Species"), sep = " ")$sci
  })
}
