\name{findSpecies}
\alias{findSpecies}
\title{Return fish matching the search names}
\usage{
  findSpecies(species, fish.data)
}
\arguments{
  \item{species}{a list of species names as "Genus_species"
  or "Genus species"}

  \item{fish.data}{the fishbase database or a subset}
}
\value{
  a logical vector of length(fish.data) indicating the
  matches, that can be used to subset the full database in
  calls to other functions.
}
\description{
  Return fish matching the search names
}
\details{
  underscores

  are removed automatically.  Later versions may check
  names
}
\examples{
## The distribution of maximum depth in Arctic fishes
#data(fishbase)
#require(ape)
#data(labridtree)
#myfish <- findSpecies(tree$tip.label, fish.data)
#getDepth(fish.data[myfish])
}

