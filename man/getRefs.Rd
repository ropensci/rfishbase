\name{getRefs}
\alias{getRefs}
\title{Returns the FishBase reference id numbers matching a query.}
\usage{
  getRefs(using = c("trophic", "habitat", "lifecycle", "morphology", "diagnostic", "distribution", "ScientificName", "Genus", "Family", "Class", "Order", "size"),
    fish.data = NULL, path = NULL)
}
\arguments{
  \item{using}{which entry type for the search}

  \item{fish.data}{the fishbase database or a subset}

  \item{path}{to cached copy of fishbase (optional,
  defaults to copy in package).}
}
\description{
  Returns the FishBase reference id numbers matching a
  query.
}
\examples{
a <- which_fish("invertebrates", "trophic")
refs <- getRefs("trophic", fish.data[a])
toprefs <- sort(table(unlist(refs)), decreasing=TRUE)
}
\keyword{utilities}

