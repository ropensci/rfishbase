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
                          server = getOption("FISHBASE_API", "fishbase"), 
                          version = get_latest_release(),
                          db = default_db()){
  
  comnames <- get_comnames(server, version, db) %>% dplyr::collect()
  subset <- 
    purrr::map_dfr(x, function(y){
      y <- stringr::str_to_lower(y)
      y <- enquo(y) 
      dplyr::filter(comnames, grepl(!!y, stringr::str_to_lower(ComName)))
    })
  
  subset
} 


get_comnames <- function(server = getOption("FISHBASE_API", "fishbase"), 
                         version = get_latest_release(),
                         db = default_db(),
                         lang = "English"){  
  ## FIXME switch to SLB if server indicates
  df <- fb_tbl("comnames", server, version, db)
  Language <- rlang::sym("Language")
  value <- rlang::quo(lang)
  comnames <- df %>% 
    dplyr::select("ComName", "Language", "SpecCode") %>%  
    dplyr::filter(!!Language == !!value) %>% 
    dplyr::distinct() %>% 
    dplyr::left_join(fb_species(server, version, db), by = "SpecCode") %>% 
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
#' @details Note that there are many common names for a given sci name, so sci_to_common doesn't make sense
#' 
#' @export common_names sci_to_common
#' @aliases common_names sci_to_common
common_names <- function(species_list = NULL, 
                         server = getOption("FISHBASE_API", "fishbase"), 
                         version = get_latest_release(),
                         db = default_db(),
                        Language = "English",
                        fields = NULL){
  species_subset(species_list, 
                 get_comnames(server, version, db, lang = Language), 
                 server, version, db) %>% 
    dplyr::collect()
}  


    
#' @export
sci_to_common <- common_names

