#' speciesnames
#' 
#' returns species names given FishBase's SpecCodes
#' 
#' @param codes a vector of speccodes (e.g. column from a table)
#' @param all_taxa the taxa table, usually loaded by default
#' @return A character vector of species names for the SpecCodes
#' @inheritParams species
#' @importFrom dplyr select_
#' @importFrom tidyr unite_
#' @export speciesnames species_names
#' @aliases speciesnames species_names
species_names <- function(codes, server =  getOption("FISHBASE_API", FISHBASE_API), all_taxa = load_taxa(server = server)){
  sapply(codes, function(x){ 
    df <- taxa(list(SpecCode = x), all_taxa = all_taxa)
    sci_names <- dplyr::select_(df, "Genus", "Species")
    tidyr::unite_(sci_names, "sci", c("Genus", "Species"), sep = " ")$sci
  })
}



speciesnames <- function(codes, all_taxa = load_taxa()) {
  warning("speciesnames() is deprecated, please use species_names()")
  species_names(codes, all_taxa)
}