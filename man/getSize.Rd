\name{getSize}
\alias{getSize}
\title{Returns available size data of specified type (length, weight, or age)}
\usage{
  getSize(fish.data = NULL,
    value = c("length", "weight", "age"), path = NULL)
}
\arguments{
  \item{fish.data}{the fishbase database or a subset}

  \item{value}{the measure to return: maximum recorded
  length (cm), maximum weight (g), or maximum age (years).
  Defaults to length; many entries lack weight and age.}

  \item{path}{to updated copy of the cache; optional.}
}
\value{
  a numeric vector of length(fish.data) with the values
  requested
}
\description{
  Returns available size data of specified type (length,
  weight, or age)
}
\examples{
data(fishbase)
yr <- getSize(fish.data, "age")
hist(yr, breaks=40, main="Age Distribution", xlab="age (years)");
nfish <- length(fish.data)
}
\keyword{utilities}

