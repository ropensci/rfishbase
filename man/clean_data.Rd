\name{clean_data}
\alias{clean_data}
\title{clean the fish.base data into pure ASCII}
\usage{
  clean_data(fish.data)
}
\arguments{
  \item{a}{list item with fishbase data}
}
\value{
  the item scrubbed of non-ASCII characters
}
\description{
  clean the fish.base data into pure ASCII
}
\examples{
\dontrun{
 updateCache()  # Update the entire database, takes hour or so
 readCache(".") # Read in the new data
 fish.data <- clean_data(fish.data) # clean the new data of non-ascii
 save(fish.data, "data/fishbase.rda") # Save over the old data
 tools:::resaveRdaFiles("data/fishbase.rda") # Compress the data file
 # Update documentation of the data in R/fishbase.R
}
}
\keyword{internal}

