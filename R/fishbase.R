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

  # these are probably guessed by xmlNamespaceDefinitions in the xpath functions
  namespaces <- c(xsd="http://www.w3.org/2001/XMLSchema", 
                  dc="http://purl.org/dc/elements/1.1/", 
                  dcterms="http://purl.org/dc/terms/", 
                  geo="http://www.w3.org/2003/01/geo/wgs84_pos#", 
                  dwc="http://rs.tdwg.org/dwc/dwcore/", 
                  xsi="http://www.w3.org/2001/XMLSchema-instance", 
                  schemaLocation="http://www.eol.org/transfer/content/0.1")


  tt <- getURLContent(url, followlocation=TRUE, curl=curl)
  doc <- xmlParse(tt)
  Genus <- xmlValue(getNodeSet(doc, "//dwc:Genus", 
                  namespaces=namespaces)[[1]])
  Family <- sapply(getNodeSet(doc, "//dwc:Family", 
                   namespaces=namespaces), xmlToList) 
  ScientificName <- sapply(getNodeSet(doc, "//dwc:ScientificName", 
                           namespaces=namespaces), xmlToList)
 
  # Size information: go to the parent node of the dc:identifier node
  # which has FB-Size-2 property.  The child of that node which is a dc:description
  # is where we'll find the size information
  size_node <- getNodeSet(doc, "//dc:identifier[string(.) = 'FB-Size-2']/..", namespaces)
  size <- xmlValue( size_node[[1]][["description"]] )
  # Likewise for distribution information
  dist_node <- getNodeSet(doc, "//dc:identifier[string(.) = 'FB-Distribution-2']/..", namespaces)
  distribution <- xmlValue( dist_node[[1]][["description"]] )

  # Format the output 
 list(Genus=Genus, Family=Family, ScientificName=ScientificName,
      distribution=distribution, size=size)
}


