#' @importFrom magrittr %>%
#' @export
magrittr::`%>%`


#memoise::cache_filesystem()
#memoise::memoise()


#' @importFrom memoise memoise
#' @importFrom readr read_tsv
fb_tbl <- 
  memoise::memoise(
  function(tbl, ...){
    addr <- 
      paste0("https://github.com/ropensci/rfishbase/releases/download/",
             "data/fb.2f", tbl, ".tsv.bz2")
    tmp <- tempfile(tbl, fileext = ".tsv.bz2")
    download.file(addr, tmp, quiet = TRUE)
    suppressWarnings( # Ignore parsing failure messages for now
    suppressMessages(out <- readr::read_tsv(tmp, ...))
    )
    unlink(tmp)
    
    out
})

## Define function that maps sci names to SpecCode, subsets table by requested sci name or spec code
#' @importFrom dplyr mutate select
fb_species <- memoise::memoise(function(server = getOption("FISHBASE_API", FISHBASE_API)){
  load_taxa(server = server) %>% dplyr::select(SpecCode, Species)
})
