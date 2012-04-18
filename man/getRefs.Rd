\name{getRefs}
\alias{getRefs}
\title{Returns all quantitative trait values found in the morphology data}
\usage{
  getRefs(using = c("trophic", "habitat", "lifecycle", "morphology", "diagnostic", "distribution", "ScientificName", "Genus", "Family", "Class", "Order", "size"),
    fish.data = NULL, path = NULL)
}
\arguments{
  \item{using}{which entry type for the search?}

  \item{fish.data}{the fishbase database or a subset}

  \item{path}{to cached copy of fishbase (optional,
  defaults to copy in package).}
}
\description{
  Returns all quantitative trait values found in the
  morphology data
}
\examples{
a <- which_fish("invertebrates", "trophic")
refs <- getRefs("trophic", fish.data[a])
}
\keyword{utilities}

