#' getPictures from the fishbase database
#' 
#' get urls of fishbase images given a genus and species
#' @param scientific name the space-separated genus and species names
#' @param type the kind of photo requested: adult, juvenile, larvae, or stamps.  
#' @param what character specifying what to return: actual image, thumbnail, or author name? 
#' @param download logical, download to working directory?
#' @param ... additional options to download.file
#' @return list of image urls.  If download=TRUE, will also dowload images to working directory.  
#' @import RCurl
#' @import XML
#' @export
getPictures <- function(scientific_name, type=c("adult", "juvenile", "larvae", "stamps"), 
                        what = c("actual", "thumbnail", "author"), download = FALSE,
                        ...){
  genus <- strsplit(scientific_name, " ")[[1]][1]
  species <- strsplit(scientific_name, " ")[[1]][2]
  what <- match.arg(what)
  type <- match.arg(type)
  url <- paste0("http://www.fishbase.org/webservice/Photos/FishPicsList.php?Genus=", genus, "&Species=", species)
  doc <- xmlParse(url)
  xpath <- paste0("//pictures[@type = '", type, "']/", what)
  imgs <- xpathSApply(doc, xpath, xmlValue)

  if(what == "author") 
    download = FALSE
  if(download)
    sapply(imgs, function(x) download.file(x, basename(x), ...))
  imgs
}



