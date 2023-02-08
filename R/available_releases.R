
#' List available releases
#' 
#' @param server fishbase or sealifebase
#' @details Lists all available releases (year.month format).  
#' To use a specific release, set the desired release using
#' `options(FISHBASE_VERSION=)`, as shown in the examples. 
#' Otherwise, rfishbase will use the latest available version if this
#' option is unset.  NOTE: it will be necessary 
#' to clear the cache with `clear_cache()` or by restarting the R session
#' with a fresh environment.  
#' @export
#' @examplesIf interactive()
#' available_releases()
#' options(FISHBASE_VERSION="19.04")
#' ## unset
#' options(FISHBASE_VERSION=NULL)
#' @importFrom stats na.omit
available_releases <- function(server = c("fishbase", "sealifebase")){
  prov <- read_prov(server)
  
  who <- names(prov)
  if("@graph" %in% who){
    prov <- prov[["@graph"]]
  } else {
    prov <- list(prov)
  }
  
  avail_versions <-  map_chr(prov, "version", .default=NA)
  as.character(sort(na.omit(avail_versions), TRUE))
  
}

#' @importFrom purrr map_chr
#' @importFrom stringr str_extract
get_latest_release <- function(server = c("fishbase", "sealifebase")) {
  available_releases(server)[[1]]
}


get_release <- function(){
  
  version <- getOption("FISHBASE_VERSION")
  if(is.null(version))
    version <- Sys.getenv("FISHBASE_VERSION")
  if(version == "")
    version <- get_latest_release()
  version
}
