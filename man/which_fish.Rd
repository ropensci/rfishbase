\name{which_fish}
\alias{which_fish}
\title{which_fish is the the generic search function for fishbase
 a variety of description types}
\usage{
  which_fish(keyword,
    using = c("trophic", "habitat", "lifecycle", "morphology", "diagnostic", "distribution", "ScientificName", "Genus", "Family", "Class", "Order", "size"),
    fish.data = NULL, path = NULL)
}
\arguments{
  \item{keyword}{pattern to be used by grep}

  \item{using}{the type of search, one of: "trophic",
  "habitat", "lifecycle", "morphology","diagnostic",
  "distribution", "ScientificName", "Genus", "Family",
  "Class", "Order", or "size" See examples.}

  \item{fish.data}{the fishbase database fish.data or a
  subset}

  \item{path}{to cached copy of fishbase (optional,
  defaults to copy in package).}
}
\value{
  a logical vector of length(fish.data) indicating the
  matches.
}
\description{
  which_fish is the the generic search function for
  fishbase a variety of description types
}
\examples{
data(fishbase)
invert <- which_fish("invertebrate|mollusk", using="trophic", fish.data)
fish_names(fish.data[invert])
sex_swap <- which_fish("change sex", using="lifecycle", fish.data)
africa <- which_fish("Africa", using="distribution", fish.data)
## recall we can sub-set
fish_names(fish.data[africa & sex_swap])
reef <- which_fish("reef", "habitat", fish.data)
redfish  <- which_fish(" red ", "diagnostic", fish.data)
bluefish  <- which_fish(" blue ", "diagnostic", fish.data)
sum(redfish) > sum(bluefish)
}
\seealso{
  fish_names
}
\keyword{utilities}

