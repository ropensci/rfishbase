#' @importFrom magrittr %>%
#' @export
magrittr::`%>%`


#memoise::cache_filesystem()
#memoise::memoise()




FISHBASE_API <- "fishbase" 


get_release <- function(){
  
  version <- getOption("FISHBASE_VERSION")
  if(is.null(version))
    version <- Sys.getenv("FISHBASE_VERSION")
  if(version == "")
    version <- get_latest_release()
  version
}

#' List available releases
#' 
#' 
#' @details Lists all available releases (year.month format).  
#' To use a specific release, set the desired release using
#' `options(FISHBASE_VERSION=)`, as shown in the examples. 
#' Otherwise, rfishbase will use the latest available version if this
#' option is unset.  NOTE: it will be necessary 
#' to clear the cache with `clear_cache()` or by restarting the R session
#' with a fresh environment.  
#' @export
#' @examples
#' available_releases()
#' options(FISHBASE_VERSION="19.04")
#' ## unset
#' options(FISHBASE_VERSION=NULL)
available_releases <- function(){
  gh::gh("/repos/:owner/:repo/releases", owner = "ropensci", repo="rfishbase") %>%
    purrr::map_chr("tag_name") %>%
    stringr::str_extract("\\d\\d\\.\\d\\d") %>% 
    as.numeric() %>% 
    na.omit() %>%
    unique() %>% 
    sort(decreasing = TRUE) %>% 
    as.character()
  
}

#' @importFrom gh gh
#' @importFrom purrr map_chr
#' @importFrom stringr str_extract
get_latest_release <- function() {
  available_releases()[[1]]
}

  # "https://fishbase.ropensci.org"
  # <- "https://fishbase.ropensci.org/sealifebase"


#' @importFrom memoise memoise
#' @importFrom readr read_tsv cols col_character type_convert
fb_tbl <- 
  memoise::memoise(
  function(tbl, server = NULL, ...){
    
    ## Handle versioning
    if(is.null(server)) 
      server <- getOption("FISHBASE_API", FISHBASE_API)
    dbname <- "fb"
    if(grepl("sealifebase", server)){
      dbname <- "slb"
    } 
    release <- paste0(dbname, "-",  
                      get_release())
    
    
    addr <- 
      paste0("https://github.com/ropensci/rfishbase/releases/download/", 
             release, "/", dbname, 
             ".2f", tbl, ".tsv.bz2")
    tmp <- tempfile(tbl, fileext = ".tsv.bz2")
    download.file(addr, tmp, quiet = TRUE)
    suppressWarnings( # Ignore parsing failure messages for now
    suppressMessages({
      tmp_out <- readr::read_tsv(tmp, ..., col_types = readr::cols(.default=readr::col_character()))
      out <- readr::type_convert(tmp_out)
    }))
    unlink(tmp)
    
    out
})

#' Clear rfishbase cache
#' 
#' rfishbase caches data downloads for faster access.  Use this to reset 
#' the cache when changing versions of rfishbase. 
#' @export
clear_cache <- function(){
  memoise::forget(fb_tbl)
  memoise::forget(fb_species)
}

## Define function that maps sci names to SpecCode, subsets table by requested sci name or spec code
#' @importFrom dplyr mutate select
fb_species <- memoise::memoise(function(server = NULL){
  load_taxa(server = server) %>% dplyr::select(SpecCode, Species)
})
