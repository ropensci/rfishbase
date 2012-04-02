\name{habitatSearch}
\alias{habitatSearch}
\title{A function to search for the occurances of any keyword in habitat description}
\usage{
  habitatSearch(keyword, fish.data)
}
\arguments{
  \item{keyword}{pattern to be used by grep}

  \item{fish.data}{the fishbase database fish.data or a
  subset,}
}
\value{
  a logical vector of length(fish.data) indicating the
  matches, that can be used to subset the full database in
  calls to other functions.
}
\description{
  A function to search for the occurances of any keyword in
  habitat description
}
\details{
  Depricated.  This functionality is provided by
  which_fish.
}
\examples{
data(fishbase)
freshwater <- habitatSearch("feshwater", fish.data)
fish.data[freshwater]
}
\keyword{utilities}

