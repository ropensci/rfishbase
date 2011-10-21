\name{getQuantTraits}
\alias{getQuantTraits}
\title{Return quantitative trait values from morphology data, if available}
\usage{
  getQuantTraits(fish.data)
}
\arguments{
  \item{fish.data}{the fishbase database or a subset}
}
\value{
  a matrix of traits by fish. Returns min-max numbers
  recorded for vertebrae, spines (anal and dorsal), and
  rays (anal and dorsal).
}
\description{
  Return quantitative trait values from morphology data, if
  available
}
\examples{
data(fishbase)
## The distribution of anal ray fins in red-colored fish
redfish  <- which_fish(" red ", "diagnostic", fish.data)
traits <- getQuantTraits(fish.data[redfish])
hist(traits[, "min.anal.rays"])
}
\keyword{utilities}

