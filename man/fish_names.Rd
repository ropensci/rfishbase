\name{fish_names}
\alias{fish_names}
\title{Return the scientific names, families, classes, or orders of the input data}
\usage{
  fish_names(fish.data = NULL,
    name = c("ScientificName", "Family", "Class", "Order"),
    path = NULL)
}
\arguments{
  \item{name}{return the Scientific Name or Family, Class,
  or Order.}

  \item{fish.data}{the fishbase database fish.data or a
  subset. Defaults to cached copy}

  \item{path}{to updated copy of the cache; optional.}
}
\value{
  the names of the matching fish.
}
\description{
  Return the scientific names, families, classes, or orders
  of the input data
}
\examples{
data(fishbase)
sex_swap <- which_fish("change sex", using="lifecycle", fish.data)
africa <- which_fish("Africa", using="distribution", fish.data)
fish_names(fish.data[africa & sex_swap])
}
\keyword{utilities}

