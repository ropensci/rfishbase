\name{getDepth}
\alias{getDepth}
\title{Returns available depth range data}
\usage{
getDepth(fish.data = NULL, path = NULL)
}
\arguments{
  \item{fish.data}{the fishbase database or a subset}

  \item{path}{to cached copy of fishbase (optional,
  defaults to copy in package).}
}
\value{
a matrix of traits by fish.  Returns min-max depth, min-max
usual depth
}
\description{
Returns available depth range data
}
\examples{
## The distribution of maximum depth in Arctic fishes
data(fishbase)
arctic  <- which_fish(" Arctic ", "distribution", fish.data)
traits <- getDepth(fish.data[arctic])
hist(traits[, "deep"])
}

