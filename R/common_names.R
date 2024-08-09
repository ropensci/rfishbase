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
#' @examplesIf interactive()
#' \donttest{
#' common_to_sci(c("Bicolor cleaner wrasse", "humphead parrotfish"), Language="English")
#' common_to_sci(c("Coho Salmon", "trout"))
#' }
#' @seealso \code{\link{species_list}}, \code{\link{synonyms}}
#' @export
#' @importFrom dplyr filter select distinct collect
#' @importFrom stringr str_to_lower
#' @importFrom purrr map_dfr
common_to_sci <- function(x, 
                          Language = "English", 
                          server = c("fishbase", "sealifebase"), 
                          version = "latest",
                          db = NULL){
  
  comnames <- get_comnames(server, version)
  subset <- 
    purrr::map_dfr(x, function(y){
      y <- stringr::str_to_lower(y)
      y <- rlang::enquo(y) 
      dplyr::filter(comnames, grepl(!!y, stringr::str_to_lower(ComName)))
    })
  
  subset
} 


get_comnames <- function(server = c("fishbase", "sealifebase"), 
                         version = "latest",
                         db = NULL,
                         lang = "English"){ 
  ## Many spec-codes may have multiple Common Names in a given language!
  sp_names <- fb_species(server, version)
  df <- fb_tbl("comnames", server, version)
  Language <- rlang::sym("Language")
  value <- rlang::quo(lang)
  comnames <- df %>% 
    dplyr::select("ComName", "Language", "SpecCode") %>%  
    dplyr::filter(!!Language == !!value) %>% 
    dplyr::distinct() %>% 
    dplyr::left_join(sp_names, by = "SpecCode") %>% 
    dplyr::select("Species", "ComName", "Language", "SpecCode")
  
  comnames
}

globalVariables(c("ComName", "Language"))
#' common names
#' 
#' Return a table of common names
#' @inheritParams species
#' @param Language a string specifying the language for the common name, e.g. "English"
#' @return a data.frame of common names by species queried. If multiple species are queried,
#' The resulting data.frames are concatenated. 
#' @details Note that there are many common names for a given sci name
#' 
#' @export common_names sci_to_common
#' @aliases common_names sci_to_common
#' @examplesIf interactive()
#' common_names("Bolbometopon muricatum")
#' 
common_names <- function(species_list = NULL, 
                         server = c("fishbase", "sealifebase"), 
                         version = "latest",
                         db = NULL,
                        Language = "English",
                        fields = NULL){

  get_comnames(server, version, db, lang = Language) |>
    filter(Species %in% species_list)
}  


    
#' @export
sci_to_common <- common_names

