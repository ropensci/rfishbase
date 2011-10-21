\name{getDepth}
\alias{getDepth}
\title{Return available depth ranges}
\usage{
  getDepth(fish.data)
}
\arguments{
  \item{fish.data}{the fishbase database or a subset}
}
\value{
  a matrix of traits by fish. Returns min-max depth,
  min-max usual depth
}
\description{
  Return available depth ranges
}
\examples{
## The distribution of maximum depth in Arctic fishes
data(fishbase)
arctic  <- which_fish(" Arctic ", "distribution", fish.data)
traits <- getDepth(fish.data[arctic])
hist(traits[, "deep"])
}

