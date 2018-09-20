#' @importFrom magrittr %>%
#' @export
magrittr::`%>%`


#memoise::cache_filesystem()
#memoise::memoise()




FISHBASE_API <- "fishbase" 
FISHBASE_VERSION <- "17.07"
  
  # "https://fishbase.ropensci.org"
  # <- "https://fishbase.ropensci.org/sealifebase"


#' @importFrom memoise memoise
#' @importFrom readr read_tsv
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
                      getOption("FISHBASE_VERSION", FISHBASE_VERSION))
    
    
    addr <- 
      paste0("https://github.com/ropensci/rfishbase/releases/download/", 
             release, "/", dbname, 
             ".2f", tbl, ".tsv.bz2")
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
fb_species <- memoise::memoise(function(server = NULL){
  load_taxa(server = server) %>% dplyr::select(SpecCode, Species)
})
