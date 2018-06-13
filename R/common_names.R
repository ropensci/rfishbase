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
#' Setting the language used explicitly will decrease the data transferred and speed up the function. 
#' The limit default is quite high in this call, as it corresponds to the number of common names that
#' match a given species, including different languages and countries. 
#' @examples
#' \donttest{
#' common_to_sci(c("Bicolor cleaner wrasse", "humphead parrotfish"), Language="English")
#' common_to_sci(c("Coho Salmon", "trout"))
#' }
#' @seealso \code{\link{commonnames}}, \code{\link{species_list}}, \code{\link{synonyms}}
#' @export
#' @importFrom dplyr filter select distinct
#' @importFrom stringr str_to_lower
#' @importFrom purrr map_dfr
common_to_sci <- function(x, Language = NULL, limit = NULL, 
                          server = getOption("FISHBASE_API", FISHBASE_API)){
  
  ## FIXME switch to SLB if server indicates
  df <- fb_tbl("comnames")
  
  comnames <- df %>% 
    dplyr::select(ComName, Language, SpecCode) %>%  
    dplyr::filter(Language %in% Language) %>% 
    dplyr::distinct()
  
  
  subset <- 
    purrr::map_dfr(x, function(y){
      y <- stringr::str_to_lower(y)
      y <- enquo(y) 
      dplyr::filter(comnames, grepl(!!y, stringr::str_to_lower(ComName)))
    })
  output <- dplyr::left_join(subset, fb_species) %>% 
    select(species, ComName, Langauge, SpecCode)
  output
} 


#' commonnames
#' 
#' Return a table of common names
#' @inheritParams species
#' @param Language a string specifying the language for the common name, e.g. "English"
#' @return a data.frame of common names by species queried. If multiple species are queried,
#' The resulting data.frames are concatenated. 
#' @details Note that there are many common names for a given sci name, so sci_to_common doesn't make sense
#' 
#' @examples
#' \dontrun{
#' common_names(c("Labroides bicolor",  "Bolbometopon muricatum"))
#' 
#' # subset by English language names
#' fish <- common_names("Bolbometopon muricatum")
#' library(dplyr)
#' fish %>% filter(Language=="English") 
#' }
#' @importFrom lazyeval interp
#' @importFrom dplyr bind_rows filter_ left_join select_
#' @importFrom httr GET
#' @export common_names commonnames
#' @aliases common_names commonnames
common_names <- function(species_list, 
                        limit = 1000, 
                        server = getOption("FISHBASE_API", FISHBASE_API), 
                        Language = NULL,
                        fields = c('ComName', 'Language','C_Code', 'SpecCode')){
  
  codes <- speccodes(species_list)
  
  dplyr::bind_rows(lapply(codes, function(code){
    resp <- httr::GET(paste0(server, "/comnames"), 
                query = list(SpecCode = code, 
                             limit = limit, 
                             fields = paste(fields, collapse=",")),
                user_agent(make_ua()))
    df <- check_and_parse(resp)
    if (is.null(df)) return(NULL)
    
    # Replace / Join SpecCode with Genus and Species columns
    id_df <- dplyr::select_(taxa(query = list(SpecCode = code)), "Genus", "Species", "SpecCode")
    df <- dplyr::left_join(df, id_df, by = "SpecCode")
    
    if(!is.null(Language) && "Language" %in% names(df)){
      .dots <- list(lazyeval::interp(~Language == x, .values = list(x = Language)))
      df <- dplyr::filter_(df, .dots=.dots)
    }
    return(df)
    # FIXME Replace C_Code with Country usiong countref table: "SELECT PAESE FROM countref WHERE C_Code=x"
  }))
}

commonnames <- function(species_list, 
                        limit = 1000, 
                        server = getOption("FISHBASE_API", FISHBASE_API), 
                        Language = NULL,
                        fields = c('ComName', 'Language','C_Code', 'SpecCode')){
  warning("commonnames() is deprecated, please use the function: common_names() instead")
  common_names(species_list, limit, server, Language, fields)
}


#' sci_to_common
#' 
#' Return the preferred FishBase common name given a scientific name (or speccode)
#' @return The common name, if it exists
#' @inheritParams species
#' @param Language the language for the common name, see details.
#' @details If Language is NULL, the common name is 
#' the preferred FishBase common name (in English).  Otherwise it 
#' is the most frequently used common name (which may not be the same
#' as the FishBase common name even with English as the requested Language)
#' @examples \dontrun{
#' sci_to_common("Salmo trutta")
#' sci_to_common("Salmo trutta", Language="English")
#' sci_to_common("Salmo trutta", Language="French")
#' }
#' @export
sci_to_common <- function(species_list,
                          Language = NULL,
                          limit = 1000,
                          server = getOption("FISHBASE_API", FISHBASE_API)){
  
  if(is.null(Language)){
    out <- sapply(species_list, function(s){
      code <- speccodes(s)
      df <- taxa(list(SpecCode = code))
      sci_names <- select_(df, "FBname")
      sci_names[["FBname"]]
    })  
  } else {
    ## based on most freq name in commonnames table
    out <- sapply(species_list, function(s){
      df <- common_names(s, Language = Language, limit = limit)
      names(which.max(table(df$ComName)))
    })
  }
  unname(out)
}
