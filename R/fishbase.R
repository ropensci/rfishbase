# file: fishbase.R
# author: Carl Boettiger <cboettig@gmail.com>
# date: 22 Aug 2011
# Description: Grab information from fishbase XML files 



#' A cached copy of extracted FishBase data, 14 Febuary 2013.  
#' @name fish.data
#' @docType data
#' @references Froese, R. and D. Pauly. Editors. 2011.FishBase.
#'   World Wide Web electronic publication.
#'   \url{www.fishbase.org}, version (10/2011).
#' @keywords data
NULL

#' An example phylogeny of labrid fish
#' @name labridtree
#' @docType data
#' @references Price, S. a, Wainwright, P. C., Bellwood, D. R., 
#' Kazancioglu, E., Collar, D. C., & Near, T. J. (2010). 
#' Functional innovations and morphological diversification in parrotfishes. 
#' Evolution; international journal of organic evolution, 
#' 3057-3068. doi:10.1111/j.1558-5646.2010.01036.x
#' @keywords data
NULL




#' Query the XML page of fishbase given a fishbase id 
#' and return the XML R object
#' @param fish.id the id number used by fishbase, ranges 1:70000
#'  though wiht many missing values
#' @param curl curlHandle(), please store value to avoid repeated handshaking. 
#' @param server the index of the server to use.  1 is sinica (Tiawan), 2 is US.
#' @return a list object with the contents of the major datatypes in the 
#'   the fishbase database.  
#' @details Typically this function will only be called internally by
#'   the caching function. 
#' @keywords internal
#' @seealso \code{\link{getData}} and \code{\link{updateCache}}.  
#' @import XML
#' @import RCurl
#' @examples \dontrun{ 
#'   # NileTilapia <- fishbase("2")
#' }
fishbase <- function(fish.id, curl=getCurlHandle(), server=2){
  servers <- c("http://fishbase.sinica.edu.tw/", "http://www.fishbase.us/")
  
  # Grab and parse page matching id
  url <- paste(servers[server],
               "maintenance/FB/showXML.php?identifier=FB-",
              fish.id, "&ProviderDbase=03", sep="")
  tt <- getURLContent(url, followlocation=TRUE, curl=curl)
  doc <- xmlParse(tt)

  ## Set defaults in case values aren't found
  Family=NULL; ScientificName=NULL; distribution=NULL; size=NULL
  size_values=NULL; habitat=NULL; trophic=NULL; lifecycle=NULL;
  morphology=NULL; diagnostic=NULL


  # these are probably guessed by xmlNamespaceDefinitions function in the 
  # xpath function calls, so could be ommitted. We only need these
  # two namespaces, so we'll just load them.  
  namespaces <- c(dc="http://purl.org/dc/elements/1.1/", 
                  dwc="http://rs.tdwg.org/dwc/dwcore/")

  ## Let's try and read our first value:
  genus_node <- getNodeSet(doc, "//dwc:Genus", 
                  namespaces=namespaces)

  
  ## Exit if no Genus (blank page).
  if(is.null(genus_node) | length(genus_node) != 1){
    warning(paste("ID", fish.id, "has no public data"))
    output <- NULL
  } else {
    Genus <- xmlValue(genus_node[[1]])
    Family <- sapply(getNodeSet(doc, "//dwc:Family", 
                     namespaces=namespaces), xmlToList)
    Order <- sapply(getNodeSet(doc, "//dwc:Order", 
                     namespaces=namespaces), xmlToList)
    Class <- sapply(getNodeSet(doc, "//dwc:Class", 
                     namespaces=namespaces), xmlToList)
    ScientificName <- sapply(getNodeSet(doc, "//dwc:ScientificName", 
                             namespaces=namespaces), xmlToList)
   
    # Size information: go to the parent node of the dc:identifier node
    # which has FB-Size-2 property.  The child of that node which is a
    # dc:description node is where we'll find the size information
    node <- getNodeSet(doc, paste("//dc:identifier[string(.) =
                            'FB-Size-", fish.id, "']/..", sep=""), namespaces)
    if(length(node)==1){
      size <- xmlValue(node[[1]][["description"]] )

      # Have to do some grep processing to extract the size information 
      # as numbers instead of this text description.
      length <- gsub("^((\\d|,)*\\.?\\d*) cm.+", "\\1", size)
      length <- as.numeric(gsub(",", "", length)) # remove commas
      units <- gsub(".+published weight: \\d.* (g|kg).+", "\\1", size)
      weight<-gsub(".+published weight: ((\\d|,)*\\.?\\d*) (g|kg).+",
                   "\\1", size)
      weight <- as.numeric(gsub(",", "", weight)) # remove commas
      if(units=="kg") 
        weight <- weight*1000
      age <-  as.numeric(gsub(".+reported age: (\\d.*) years.*", "\\1", size))
      size_values <- c(length=length, weight=weight, age=age)  
    } 

    node <- getNodeSet(doc, paste("//dc:identifier[string(.) =
                            'FB-Distribution-", fish.id, "']/..", sep=""),
                            namespaces)
    if(length(node) == 1)
      distribution <- xmlValue(node[[1]][["description"]] )

    node <- getNodeSet(doc, paste("//dc:identifier[string(.) =
                            'FB-Habitat-", fish.id, "']/..", sep=""),
                            namespaces)
    if(length(node) == 1)
      habitat <- xmlValue(node[[1]][["description"]] )

    
    node <- getNodeSet(doc, paste("//dc:identifier[string(.) =
                            'FB-TrophicStrategy-", fish.id, "']/..", sep=""),
                            namespaces)
    if(length(node) == 1)
      trophic <- xmlValue( node[[1]][["description"]] )

    node <- getNodeSet(doc, paste("//dc:identifier[string(.) =
                            'FB-LifeCycle-", fish.id, "']/..", sep=""),
                            namespaces)
    if(length(node) == 1)
      lifecycle <- xmlValue( node[[1]][["description"]] )

    node <- getNodeSet(doc, paste("//dc:identifier[string(.) =
                            'FB-Morphology-", fish.id, "']/..", sep=""),
                            namespaces)
    if(length(node) == 1)
      morphology <- xmlValue( node[[1]][["description"]] )

    node <- getNodeSet(doc, paste("//dc:identifier[string(.) =
                            'FB-DiagnosticDescr-", fish.id, "']/..", sep=""),
                            namespaces)
    if(length(node) == 1)
      diagnostic <- xmlValue( node[[1]][["description"]] )
  
  # Format the output 
  output <- list(Genus=Genus, Family=Family, ScientificName=ScientificName,
      distribution=distribution, size=size, size_values=size_values,
      habitat=habitat, trophic=trophic, lifecycle=lifecycle, Class=Class, 
      morphology=morphology, diagnostic=diagnostic, Order=Order, id=fish.id)
  }
  output
}

#' Description: a general function to loop over all fish ids to get data
#'   also drops the missing entries
#' @param fish.ids used by fishbase. An integer between 1:70000, though many
#'   missing values in between.  
#' @param silent a logical of whether to supress warnings.  default is TRUE
#' @return a list object with the information for those fish, if avaialble. 
#' @details Typically this function will only be called internally by
#'   the caching function.  
#' @keywords internal
#' @seealso \code{\link{getData}} and \code{\link{updateCache}}.  
#' @examples \dontrun{
#'   fish.data <- getData(1:3)
#' }
getData <- function(fish.ids, silent=TRUE){
  curl <- getCurlHandle()
  data <- 
  suppressWarnings(
    lapply(fish.ids, function(i){ 
			if(!silent) 
			  print(i)
			try(fishbase(i, curl=curl))
		      })
  )
  data <- sapply(data, function(x) if(!is(x, "try-error")) x)
  data[!sapply(data, is.null)]
}


