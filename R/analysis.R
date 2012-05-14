#' A function to search for the occurances of any keyword in habitat description
#' 
#' deprecrated, see \code{which_fish}
#' @param keyword pattern to be used by grep
#' @param fish.data the fishbase database fish.data or a subset,
#' @return a logical vector of length(fish.data) indicating the matches, that can 
#'   be used to subset the full database in calls to other functions. 
#' @keywords utilities
#' @details Depricated.  This functionality is provided by which_fish.
habitatSearch <- function(keyword, fish.data=NULL){
  which_fish(family, using="habitat", fish.data)
}



#' A function to find all fish that are members of a scientific Family 
#' 
#' deprecrated, see \code{which_fish}
#' @param family The scientific family name.  Can include grep matching, see examples 
#' @param fish.data the fishbase database or a subset
#' @return a logical vector of length(fish.data) indicating the matches.
#' @details The return value can be summed to give the number of matches, can
#'   be used as an index, e.g. fish.data[goby], to return the matches or to
#'   pass to another function.  See examples.  
#' @keywords utilities
familySearch <- function(family, fish.data=NULL){
  which_fish(family, using="Family", fish.data)
}

#' which_fish is the the generic search function for fishbase
#'  a variety of description types
#' 
#' @param keyword pattern to be used by grep
#' @param using the type of search, one of: "trophic", "habitat", "lifecycle", 
#'    "morphology","diagnostic", "distribution", "ScientificName", "Genus",
#'    "Family", "Class", "Order", or "size"  See examples.  
#' @param fish.data the fishbase database fish.data or a subset
#' @param path to cached copy of fishbase (optional, defaults to copy in package).
#' @return a logical vector of length(fish.data) indicating the matches.
#' @keywords utilities
#' @examples
#' data(fishbase) 
#' invert <- which_fish("invertebrate|mollusk", using="trophic", fish.data)
#' fish_names(fish.data[invert])
#' sex_swap <- which_fish("change sex", using="lifecycle", fish.data)
#' africa <- which_fish("Africa", using="distribution", fish.data)
#' ## recall we can sub-set
#' fish_names(fish.data[africa & sex_swap])
#' reef <- which_fish("reef", "habitat", fish.data)
#' redfish  <- which_fish(" red ", "diagnostic", fish.data) 
#' bluefish  <- which_fish(" blue ", "diagnostic", fish.data) 
#' sum(redfish) > sum(bluefish)
#' @seealso fish_names
#' 
#' @export
which_fish <- function(keyword, using=c("trophic", "habitat", "lifecycle", 
                       "morphology","diagnostic", "distribution",
                       "ScientificName", "Genus", "Family",
                       "Class", "Order", "size"), fish.data=NULL, path=NULL){
  if(is.null(fish.data))
    fish.data <- loadCache(path=path)
  using <- match.arg(using)
  sapply(fish.data, function(x) length(grep(keyword, x[[using]]))>0)
}


#' Return the scientific names, families, classes, or orders of the input data
#' 
#' @param name return the Scientific Name or Family, Class, or Order.
#' @param fish.data the fishbase database fish.data or a subset. Defaults to cached copy
#' @param path to updated copy of the cache; optional.  
#' @return the names of the matching fish.   
#' @keywords utilities
#' @examples
#' data(fishbase) 
#' sex_swap <- which_fish("change sex", using="lifecycle", fish.data)
#' africa <- which_fish("Africa", using="distribution", fish.data)
#' fish_names(fish.data[africa & sex_swap])
#' 
#' @export
fish_names <- function(fish.data=NULL, name=c("ScientificName", "Family", "Class", "Order"), path=NULL){
  if(is.null(fish.data))
    fish.data <- loadCache(path=path)
  name <- match.arg(name)
  sapply(fish.data, function(x) x[[name]])
}

#' Returns available size data of specified type (length, weight, or age) 
#' 
#' @param fish.data the fishbase database or a subset
#' @param value the measure to return: maximum recorded length (cm), 
#'   maximum weight (g), or maximum age (years). Defaults to length; many 
#'   entries lack weight and age. 
#' @param path to updated copy of the cache; optional.  
#' @return a numeric vector of length(fish.data) with the values requested 
#' @keywords utilities
#' @examples
#' data(fishbase)
#' yr <- getSize(fish.data, "age")
#' hist(yr, breaks=40, main="Age Distribution", xlab="age (years)"); 
#' nfish <- length(fish.data)
#' 
#' @export
getSize <- function(fish.data=NULL, value=c("length", "weight", "age"), path=NULL){
  if(is.null(fish.data))
    fish.data <- loadCache(path=path)
  value <- match.arg(value)
  y <- sapply(fish.data, function(x){
     z <- c("length"= NA, "weight"=NA, "age"=NA)
     y <- x$size_values
    if(length(y) < 1)
      y <- z
    for(i in 1:length(y)) 
      z[i] <- y[i]    
    as.numeric(z[[value]])
  })
  out <- unlist(y)
  species.names <- sapply(fish.data, `[[`, 'ScientificName')
  names(out) <- gsub(" ", "_", species.names) # use underscores instead of spaces
  out
}


#' Returns the matching indices in the data given a list of species names
#' 
#' @param species a list of species names as "Genus_species" or "Genus species"
#' @param fish.data the fishbase database or a subset
#' @details underscores are removed automatically.  Later versions may check names 
#     against ITIS.gov database using the taxize package.  
#' @return a logical vector of length(fish.data) indicating the matches, that can 
#'   be used to subset the full database in calls to other functions. 
#' @keywords utilities
#' @param path to cached copy of fishbase (optional, defaults to copy in package).
#' @examples
#' ## The distribution of maximum depth in Arctic fishes
#' data(fishbase)
#' data(labridtree)
#' myfish <- findSpecies(labridtree$tip.label, fish.data) 
#' getDepth(fish.data[myfish])
#' 
#' @export
findSpecies <- function(species, fish.data=NULL, path=NULL){
  if(is.null(fish.data))
    fish.data <- loadCache(path=path)
  species<-gsub("_", " ", species)
  sapply(fish.data, function(x) x$ScientificName %in% species)
}





#' Returns available depth range data
#' 
#' @param fish.data the fishbase database or a subset
#' @param path to cached copy of fishbase (optional, defaults to copy in package).
#' @return a matrix of traits by fish.  
#'   Returns min-max depth, min-max usual depth
#; @keywords utilities
#' @examples
#' ## The distribution of maximum depth in Arctic fishes
#' data(fishbase)
#' arctic  <- which_fish(" Arctic ", "distribution", fish.data) 
#' traits <- getDepth(fish.data[arctic])
#' hist(traits[, "deep"])
#'
#' @export
getDepth <- function(fish.data=NULL, path=NULL){
  if(is.null(fish.data))
    fish.data <- loadCache(path=path)
  depthfn <- function(fish){
    x <- fish$habitat
    if(is.null(x)) 
      ans <- rep(NA, 4)
    else {
      shallow <-
       as.integer(gsub(".*depth range (\\?|\\d+) - (\\?|\\d+) m.*)", "\\1", x))
      deep <-
       as.integer(gsub(".*depth range (\\?|\\d+) - (\\?|\\d+) m.*)", "\\2", x))
      usual.shallow <-
       as.integer(gsub(".*usually (\\?|\\d+) - (\\?|\\d+) m.*)", "\\1", x))
      usual.deep <-
       as.integer(gsub(".*usually (\\?|\\d+) - (\\?|\\d+) m.*)", "\\2", x))
      ans <-
       c(shallow = shallow, deep = deep, 
         usual.shallow = usual.shallow, usual.deep = usual.deep)
    }
    # handle some more error cases
    if(length(ans)==0) 
      ans <- rep(NA, 4)
    names(ans) = c("shallow", "deep", "usual.shallow", "usual.deep")
    ans
  }
  out <- t(suppressWarnings(sapply(fish.data, depthfn)))
  species.names <- sapply(fish.data, `[[`, 'ScientificName')
  rownames(out) <- gsub(" ", "_", species.names) # use underscores instead of spaces
  out
}


#' Returns all quantitative trait values found in the morphology data
#' 
#' @param fish.data the fishbase database or a subset
#' @param path to cached copy of fishbase (optional, defaults to copy in package).
#' @return a matrix of traits by fish. Returns min-max numbers 
#'   recorded for vertebrae, spines (anal and dorsal), and 
#'   rays (anal and dorsal).  
#' @keywords utilities
#' @examples
#' data(fishbase)
#' ## The distribution of anal ray fins in red-colored fish  
#' redfish  <- which_fish(" red ", "diagnostic", fish.data) 
#' traits <- getQuantTraits(fish.data[redfish])
#' hist(traits[, "min.anal.rays"])
#' 
#' @export
getQuantTraits <- function(fish.data=NULL, path=NULL){
  if(is.null(fish.data))
    fish.data <- loadCache(path=path)
  morph <- function(x){
    str <- x$morphology
    if(is.null(str)) 
      ans <- rep(NA, 10)
    else {
      # remove tabs and newlines that seem to appear in this data
      str <- gsub("\\n", " ", str)
      str <- gsub("\\t", "", str)
      # match a range if given, otherwise just match first number
      min.vertebrae <- 
       as.integer(gsub(".*Vertebrae: (\\d*)( - (\\d*))*.*", "\\1", str))
      max.vertebrae <- 
       as.integer(gsub(".*Vertebrae: (\\d*)( - (\\d*))*.*", "\\3", str))
      min.anal.spines <- 
       as.integer(gsub(".*Anal spines: (\\d*)( - (\\d*))*.*", "\\1", str))
      max.anal.spines <- 
       as.integer(gsub(".*Anal spines: (\\d*)( - (\\d*))*.*", "\\3", str))
      min.dorsal.spines <-
       as.integer(gsub(".*Dorsal spines.*: (\\d*)( - (\\d*))*.*", "\\1", str))
      max.dorsal.spines <-
       as.integer(gsub(".*Dorsal spines.*: (\\d*)( - (\\d*))*.*", "\\3", str))
      min.dorsal.rays <- 
       as.integer(gsub(".*Dorsal.* rays.*: (\\d*)( - (\\d*))*.*", "\\1", str))
      max.dorsal.rays <- 
       as.integer(gsub(".*Dorsal.* rays.*: (\\d*)( - (\\d*))*.*", "\\3", str))
      min.anal.rays <- 
       as.integer(gsub(".*Anal.* rays: (\\d*)( - (\\d*))*.*", "\\1", str))
      max.anal.rays <- 
       as.integer(gsub(".*Anal.* rays: (\\d*)( - (\\d*))*.*", "\\3", str))
      ans <- c( min.vertebrae=min.vertebrae, max.vertebrae=max.vertebrae, 
        min.anal.spines=min.anal.spines, max.anal.spines=max.anal.spines,
        min.dorsal.spines=min.dorsal.spines, max.dorsal.spines=max.dorsal.spines,
        min.dorsal.rays=min.dorsal.rays, max.dorsal.rays=max.dorsal.rays,
        min.anal.rays=min.anal.rays, max.anal.rays=max.anal.rays)
     }
    # handle some more error cases
    if(length(ans)==0)
      ans <- rep(NA, 10)
    names(ans) <- c("min.vertebrae", "max.vertebrae", "min.anal.spines", 
               "max.anal.spines", "min.dorsal.spines", "max.dorsal.spines",
               "min.dorsal.rays", "max.dorsal.rays", "min.anal.rays", 
               "max.anal.rays")
    
    ans
  }
  # Apply to the data range, ignoring warnings due to missing data
  out <- t(suppressWarnings(sapply(fish.data, morph, simplify="array")))
  species.names <- sapply(fish.data, `[[`, 'ScientificName')
  rownames(out) <- gsub(" ", "_", species.names) # use underscores instead of spaces
  out
}

#' Returns the FishBase reference id numbers matching a query. 
#'
#' @param using which entry type for the search
#' @param fish.data the fishbase database or a subset
#' @param path to cached copy of fishbase (optional, defaults to copy in package).
#' @keywords utilities
#' @examples
#' a <- which_fish("invertebrates", "trophic")
#' refs <- getRefs("trophic", fish.data[a])
#' toprefs <- sort(table(unlist(refs)), decreasing=TRUE)
#' @export
getRefs <- function(using=c("trophic", "habitat", "lifecycle", 
                    "morphology","diagnostic", "distribution",
                    "ScientificName", "Genus", "Family",
                    "Class", "Order", "size"), fish.data=NULL, path=NULL){
  if(is.null(fish.data))
    fish.data <- loadCache(path=path)
  using <- match.arg(using)
  sapply(fish.data, function(x){
    extractMatches(x[[using]], "Ref. (\\d+)")
  })
}

extractMatches <- function(data, pattern) {
    start <-  gregexpr(pattern, data)[[1]]
    stop  <-  start + attr(start, "match.length") - 1
    if(-1 %in% start) {""} else {
        mapply(substr, start, stop, MoreArgs = list(x = data))
    }
}    


