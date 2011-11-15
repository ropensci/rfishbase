\name{familySearch}
\alias{familySearch}
\title{A function to find all fish that are members of a scientific Family}
\usage{
  familySearch(family, fish.data)
}
\arguments{
  \item{family}{The scientific family name.  Can include
  grep matching, see examples}

  \item{fish.data}{the fishbase database or a subset}
}
\value{
  a logical vector of length(fish.data) indicating the
  matches.
}
\description{
  A function to find all fish that are members of a
  scientific Family
}
\details{
  The return value can be summed to give the number of
  matches, can be used as an index, e.g. fish.data[goby],
  to return the matches or to pass to another function.
  See examples.
}
\examples{
data(fishbase)
goby <- familySearch("Gobiidae", fish.data)
labrid <- familySearch("(Labridae|Scaridae)", fish.data)
## Example 2
# get all the labrids that are reefs
labrid.reef <- habitatSearch("reef", fish.data[labrid])
# How many species are reef labrids:
sum(labrid.reef)
}
\keyword{utilities}

