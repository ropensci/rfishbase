\name{findSpecies}
\alias{findSpecies}
\title{Returns the matching indices in the data given a list of species names}
\usage{
  findSpecies(species, fish.data = NULL, path = NULL)
}
\arguments{
  \item{species}{a list of species names as "Genus_species"
  or "Genus species"}

  \item{fish.data}{the fishbase database or a subset}

  \item{path}{to cached copy of fishbase (optional,
  defaults to copy in package).}
}
\value{
  a logical vector of length(fish.data) indicating the
  matches, that can be used to subset the full database in
  calls to other functions.
}
\description{
  Returns the matching indices in the data given a list of
  species names
}
\details{
  underscores are removed automatically.  Later versions
  may check names
}
\examples{
## The distribution of maximum depth in Arctic fishes
data(fishbase)
data(labridtree)
myfish <- findSpecies(tree$tip.label, fish.data)
getDepth(fish.data[myfish])
}
\keyword{utilities}

