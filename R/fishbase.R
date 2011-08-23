# file: fishbase.R
# author: Carl Boettiger <cboettig@gmail.com>
# date: 22 Aug 2011
# Description: Grab information from fishbase XML files 

fishbase <- function(fish.id, curl=getCurlHandle()){
  # Query the XML page of fishbase given a fishbase id 
  # and return the XML R object
  #
  # Examples: 
  #   NileTilapia <- fishbase("2")
  #   metadata(tree$S.id)
  #   
  url <- paste("http://fishbase.sinica.edu.tw/",
               "maintenance/FB/showXML.php?identifier=FB-",
              fish.id, "&ProviderDbase=03", sep="")
  tt <- getURLContent(url, followlocation=TRUE, curl=curl)
  doc <- xmlParse(tt)
  dc = getNodeSet(doc, "//")
#  dc = getNodeSet(doc, "//dc:dc", namespaces=c(dc="http://www.openarchives.org/OAI/2.0/oai_dc/"))
  lapply(dc, xmlToList)
 }


