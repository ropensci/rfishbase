\name{getSize}
\alias{getSize}
\title{A function to return size information from fishbase data}
\usage{
  getSize(fish.data, value = c("length", "weight", "age"))
}
\arguments{
  \item{fish.data}{the fishbase database or a subset}

  \item{value}{the measure to return: maximum recorded
  length (cm), maximum weight (g), or maximum age (years).
  Defaults to length; many entries lack weight and age.}
}
\value{
  a numeric vector of length(fish.data) with the values
  requested
}
\description{
  A function to return size information from fishbase data
}
\examples{
data(fishbase)
yr <- getSize(fish.data, "age")
hist(yr, breaks=40, main="Age Distribution", xlab="age (years)");
nfish <- length(fish.data)
}
\keyword{utilities}

