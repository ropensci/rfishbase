#' common_to_sci
#' 
#' Return a list of scientific names corresponding to given the common name(s).
#' 
#' @param x a common name or list of common names
#' @param Language a string specifying the language for the common name, e.g. "English"
#' @inheritParams species
#' @return a character vector of scientific names
#' @details If more than one scientific name matches the common name (e.g. "trout"), the function
#' will simply return a list of all matching scientific names.  If given more than one common name,
#' the resulting strings of matching scientific names are simply concatenated. 
#' 
#' @examples
#' \donttest{
#' common_to_sci(c("Bicolor cleaner wrasse", "humphead parrotfish"), Language="English")
#' common_to_sci(c("Coho Salmon", "trout"))
#' }
#' @seealso \code{\link{species_list}}, \code{\link{synonyms}}
#' @export
#' @importFrom dplyr filter select distinct
#' @importFrom stringr str_to_lower
#' @importFrom purrr map_dfr
common_to_sci <- function(x, Language = NULL, ..., 
                          server = NULL){
  
  comnames <- get_comnames(server)
  subset <- 
    purrr::map_dfr(x, function(y){
      y <- stringr::str_to_lower(y)
      y <- enquo(y) 
      dplyr::filter(comnames, grepl(!!y, stringr::str_to_lower(ComName)))
    })
  
  subset
} 


get_comnames <- memoise::memoise(function(server){  
  ## FIXME switch to SLB if server indicates
  df <- fb_tbl("comnames", server)
  comnames <- df %>% 
    dplyr::select(ComName, Language, SpecCode) %>%  
    dplyr::filter(Language %in% Language) %>% 
    dplyr::distinct() %>% 
    dplyr::left_join(fb_species(server), by = "SpecCode") %>% 
    select(Species, ComName, Language, SpecCode)
})

globalVariables(c("ComName", "Language"))
#' common names
#' 
#' Return a table of common names
#' @inheritParams species
#' @param Language a string specifying the language for the common name, e.g. "English"
#' @return a data.frame of common names by species queried. If multiple species are queried,
#' The resulting data.frames are concatenated. 
#' @details Note that there are many common names for a given sci name, so sci_to_common doesn't make sense
#' 
#' @examples
#' \donttest{
#' common_names(c("Labroides bicolor",  "Bolbometopon muricatum"))
#' 
#' # subset by English language names
#' fish <- common_names("Bolbometopon muricatum")
#' }
#' @export common_names sci_to_common
#' @aliases common_names sci_to_common
common_names <- function(species_list, 
                        server = NULL, 
                        Language = NULL,
                        fields = NULL){
  
  left_join(speccodes(species_list), get_comnames(server))
}  


    
#' @export
sci_to_common <- common_names

