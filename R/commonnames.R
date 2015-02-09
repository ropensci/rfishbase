#' 
#' @examples
#' \donttest{
#' common_to_sci(c("Bicolor cleaner wrasse", "humphead parrotfish"))
#' common_to_sci("trout")
#' common_to_sci(c("trout", "Coho Salmon"))
#' }
#' @seealso \code{\link{commonnames}}, \code{\link{species_list}}, \code{\link{synonyms}}
common_to_sci <- function(x, Language = NULL, verbose = TRUE, limit = 1000, server = SERVER){
  
  out <- sapply(x, function(x){
    # Look up SpecCode for the common names
    resp <- GET(paste0(server, "/comnames"), 
                query = list(ComName = x,
                             Language = Language,
                             limit = limit,  # SpecCode same for all matches
                             fields = 'SpecCode'))
    data <- check_and_parse(resp, verbose = verbose)
    matches <- unique(data[[1]])
    
    sci_names <- species_info(matches, fields = c("Genus", "Species"))
    unite_(sci_names, "sci_name", c("Genus", "Species"), sep = " ")$sci_name
  })
  
  # If multiple matches are found, we want to collapse
  unname(unlist(out))
}


#' Return a table of common names
#' @inheritParams species_info
#' @details Note that there are many common names for a given sci name, so sci_to_common doesn't make sense
#' 
#' @examples
#' \donttest{
#' commonnames(c("Labroides bicolor",  "Bolbometopon muricatum"))
#' 
#' # subset by English language names
#' fish <- commonnames("Bolbometopon muricatum")
#' library(dplyr)
#' fish %>% filter(Language=="English") 
#' }
#
## FIXME C_Code should be mapped to a country name using the table 'country' 
commonnames <- function(species_list, 
                        verbose = TRUE, 
                        limit = 100, 
                        server = SERVER, 
                        fields = c('ComName', 'Language','C_Code', 'SpecCode')){
  
  codes <- speccodes(species_list)
  
  bind_rows(lapply(codes, function(code){
    resp <- GET(paste0(server, "/comnames"), 
                query = list(SpecCode = code, 
                             limit = limit, 
                             fields = paste(fields, collapse=",")))
    df <- check_and_parse(resp, verbose = verbose)
    
    # Replace / Join SpecCode with Genus and Species columns
    id_df <- select_(taxa(query = list(SpecCode = code)), "Genus", "Species", "SpecCode")
    df <- left_join(df, id_df)
    
    # Replace C_Code with Country
  }))
}
