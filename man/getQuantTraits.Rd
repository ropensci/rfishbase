\name{getQuantTraits}
\alias{getQuantTraits}
\title{Returns all quantitative trait values found in the morphology data}
\usage{
  getQuantTraits(fish.data = NULL, path = NULL)
}
\arguments{
  \item{fish.data}{the fishbase database or a subset}

  \item{path}{to cached copy of fishbase (optional,
  defaults to copy in package).}
}
\value{
  a matrix of traits by fish. Returns min-max numbers
  recorded for vertebrae, spines (anal and dorsal), and
  rays (anal and dorsal).
}
\description{
  Returns all quantitative trait values found in the
  morphology data
}
\examples{
data(fishbase)
## The distribution of anal ray fins in red-colored fish
redfish  <- which_fish(" red ", "diagnostic", fish.data)
traits <- getQuantTraits(fish.data[redfish])
hist(traits[, "min.anal.rays"])
}
\keyword{utilities}

