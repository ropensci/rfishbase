# file: fishbase.R
# author: Carl Boettiger <cboettig@gmail.com>
# date: 22 Aug 2011
# Description: Grab information from fishbase XML files 

fishbase <- function(fish.id, curl=getCurlHandle()){
  # Query the XML page of fishbase given a fishbase id 
  # and return the XML R object
  #
  # common name, family, max length, max published weight, max
  # reported age, length at first maturity, range of length at first
  # maturity, environment, climate/range, distribution, short description,
  # and biology.
  #
  #
  # Examples: 
  #   NileTilapia <- fishbase("2")
  #   metadata(tree$S.id)
  #   
  url <- paste("http://fishbase.sinica.edu.tw/",
               "maintenance/FB/showXML.php?identifier=FB-",
              fish.id, "&ProviderDbase=03", sep="")

  # these are probably guessed by xmlNamespaceDefinitions function in the 
  # xpath function calls, so could be ommitted. We only need these
  # two namespaces, so we'll just load them.  
  namespaces <- c(dc="http://purl.org/dc/elements/1.1/", 
                  dwc="http://rs.tdwg.org/dwc/dwcore/")


  tt <- getURLContent(url, followlocation=TRUE, curl=curl)
  doc <- xmlParse(tt)
  Genus <- try(xmlValue(getNodeSet(doc, "//dwc:Genus", 
                  namespaces=namespaces)[[1]]))

  ## lets see if the page exists.
  if(is(Genus, "try-error")){
    output <- "try-error"
    class(output) <- "try-error"
  } else {
    Family <- xmlValue(getNodeSet(doc, "//dwc:Family", 
                     namespaces=namespaces)[[1]]) 
    ScientificName <- sapply(getNodeSet(doc, "//dwc:ScientificName", 
                             namespaces=namespaces), xmlToList)
   
    # Size information: go to the parent node of the dc:identifier node
    # which has FB-Size-2 property.  The child of that node which is a dc:description
    # is where we'll find the size information
    size_node <- getNodeSet(doc, paste("//dc:identifier[string(.) =
                            'FB-Size-", fish.id, "']/..", sep=""), namespaces)
    size <- xmlValue( size_node[[1]][["description"]] )


    # Have to do some grep processing to extract the size information 
    # as numbers instead of this text description.
    length <- gsub("^((\\d|,)*\\.?\\d*) cm.+", "\\1", size)
    length <- as.numeric(gsub(",", "", length)) # remove commas

    units <- gsub(".+published weight: \\d.* (g|kg).+", "\\1", size)
    weight <- gsub(".+published weight: ((\\d|,)*\\.?\\d*) (g|kg).+", "\\1", size)
    weight <- as.numeric(gsub(",", "", weight)) # remove commas
    if(units=="kg") 
      weight <- weight*1000
    age <-  as.numeric(gsub(".+reported age: (\\d.*) years.*", "\\1", size))
    size_values <- c(length=length, weight=weight, age=age)  

    # Likewise for distribution information 
    dist_node <- getNodeSet(doc, paste("//dc:identifier[string(.) =
                            'FB-Distribution-", fish.id, "']/..", sep=""),
                            namespaces)
    distribution <- xmlValue( dist_node[[1]][["description"]] )
    # The dist_node may have other useful information, including maps 


    # May want to mine this for keywords in a subsequent function
    habitat_node <- getNodeSet(doc, paste("//dc:identifier[string(.) =
                            'FB-Habitat-", fish.id, "']/..", sep=""), namespaces)
    habitat <- xmlValue( habitat_node[[1]][["description"]] )

    
    node <- getNodeSet(doc, paste("//dc:identifier[string(.) =
                            'FB-TrophicStrategy-", fish.id, "']/..", sep=""), namespaces)
    trophic <- xmlValue( node[[1]][["description"]] )

    node <- getNodeSet(doc, paste("//dc:identifier[string(.) =
                            'FB-LifeCycle-", fish.id, "']/..", sep=""), namespaces)
    lifecycle <- xmlValue( node[[1]][["description"]] )

    node <- getNodeSet(doc, paste("//dc:identifier[string(.) =
                            'FB-Morphology-", fish.id, "']/..", sep=""), namespaces)
    morphology <- xmlValue( node[[1]][["description"]] )

    node <- getNodeSet(doc, paste("//dc:identifier[string(.) =
                            'FB-DiagnosticDescr-", fish.id, "']/..", sep=""), namespaces)
    diagnostic <- xmlValue( node[[1]][["description"]] )
  
  # Format the output 
  output <- list(Genus=Genus, Family=Family, ScientificName=ScientificName,
      distribution=distribution, size=size, size_values=size_values,
      habitat=habitat, trophic=trophic, lifecycle=lifecycle, 
      morphology=morphology, diagnostic=diagnostic, id=fish.id)
  }
  output
}


getData <- function(fish.ids){
# Description: a general function to loop over all fish ids to get data
#   also drops the missing entries
# Example:
#   all.fishbase <- getData(1:30000)
  data <- 
  suppressWarnings(
    lapply(fish.ids, function(i) try(fishbase(i)))
  )
    lapply(data, function(x){
                  if(!is(x, "try-error"))
                    x
                 })
}


