habitatSearch <- function(keyword, fish.data){
# A function to search for the occurances of any keyword in habitat description
# Args:
#   keyword: pattern to be used by grep
#   fish.data: list of outputs from fishbase(), or from getData()
# Example:
#   data <- getData(1:10)
#   habitatSearch("feshwater", data)
  x <- sapply(fish.data, function(x) grep(keyword, x$habitat) )
  x <- as.integer(x) # clean up data 
  x[is.na(x)] <- 0   # cean up data
  as.logical(x)
}

familySearch <- function(family, fish.data){
#  x <- sapply(fish.data, function(x) x$Family==family)
  x <- sapply(fish.data, function(x) length(grep(family,x$Family)>1))
  as.logical(x)
}


getSize <- function(fish.data, value=c("length", "weight", "age")){
# A function to extract 
  value <- match.arg(value)
  y <- sapply(fish.data, function(x) x$size_values[[value]])
  unlist(y)
}

getQuantTraits <- function(fish.data){
# Return quantitative trait values from morphology data, if available
# Args:
#   keyword: pattern to be used by grep
#   fish.data: list of outputs from fishbase(), or from getData()
# Example:
#   data <- getData(1:10)
  morph <- function(x){
    str <- x$morphology
    if(is.null(str)) 
      ans <- rep(NA, 10)
    else {
    # remove tabs and newlines that seem to appear in this data
    str <- gsub("\\n", " ", str)
    str <- gsub("\\t", "", str)
    # match a range if given, otherwise just match first number
    min.vertebrae <- as.integer(gsub(".*Vertebrae: (\\d*)( - (\\d*))*.*", "\\1", str))
    max.vertebrae <- as.integer(gsub(".*Vertebrae: (\\d*)( - (\\d*))*.*", "\\3", str))
    min.anal.spines <- as.integer(gsub(".*Anal spines: (\\d*)( - (\\d*))*.*", "\\1", str))
    max.anal.spines <- as.integer(gsub(".*Anal spines: (\\d*)( - (\\d*))*.*", "\\3", str))
    min.dorsal.spines <- as.integer(gsub(".*Dorsal spines.*: (\\d*)( - (\\d*))*.*", "\\1", str))
    max.dorsal.spines <- as.integer(gsub(".*Dorsal spines.*: (\\d*)( - (\\d*))*.*", "\\3", str))
    min.dorsal.rays <- as.integer(gsub(".*Dorsal.* rays.*: (\\d*)( - (\\d*))*.*", "\\1", str))
    max.dorsal.rays <- as.integer(gsub(".*Dorsal.* rays.*: (\\d*)( - (\\d*))*.*", "\\3", str))
    min.anal.rays <- as.integer(gsub(".*Anal.* rays: (\\d*)( - (\\d*))*.*", "\\1", str))
    max.anal.rays <- as.integer(gsub(".*Anal.* rays: (\\d*)( - (\\d*))*.*", "\\3", str))
    
    ans <- c(min.vertebrae=min.vertebrae, max.vertebrae=max.vertebrae, 
      min.anal.spines=min.anal.spines, max.anal.spines=max.anal.spines,
      min.dorsal.spines=min.dorsal.spines, max.dorsal.spines=max.dorsal.spines,
      min.dorsal.rays=min.dorsal.rays, max.dorsal.rays=max.dorsal.rays,
      min.anal.rays=min.anal.rays, max.anal.rays=max.anal.rays)
    }
    ans
  }
  # Apply to the data range, ignoring warnings due to missing data
  t(suppressWarnings(sapply(fish.data, morph, simplify="array")))
}

getDepth <- function(fish.data){
  depthfn <- function(fish){
    x <- fish$habitat
    if(is.null(x)) 
      ans <- rep(NA, 4)
    else {
      shallow <- as.integer(gsub(".*depth range (\\?|\\d+) - (\\?|\\d+) m.*)", "\\1", x))
      deep <- as.integer(gsub(".*depth range (\\?|\\d+) - (\\?|\\d+) m.*)", "\\2", x))
      usual.shallow <- as.integer(gsub(".*usually (\\?|\\d+) - (\\?|\\d+) m.*)", "\\1", x))
      usual.deep <- as.integer(gsub(".*usually (\\?|\\d+) - (\\?|\\d+) m.*)", "\\2", x))
      ans <- c(shallow=shallow, deep=deep, usual.shallow=usual.shallow, usual.deep=usual.deep)
    }
    ans
  }
  t(suppressWarnings(sapply(fish.data, depthfn)))
}


findSpecies <- function(species, fish.data){
  # takes a vector of species names and queries for their id numbers in the dataset
  # ideally, it would query names against taxize to get the correct name types
  sapply(fish.data, function(x) x$ScientificName %in% species)
}


