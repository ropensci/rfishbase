\name{fish_names}
\alias{fish_names}
\title{A function to give the names of the matched fish}
\usage{
  fish_names(fish.data, name = c("ScientificName",
  "Family", "Class", "Order"))
}
\arguments{
  \item{name}{return the Scientific Name (default)? or
  Family, Class, or Order.}

  \item{fish.data}{the fishbase database fish.data or a
  subset,}
}
\value{
  the names of the matching fish.
}
\description{
  A function to give the names of the matched fish
}
\examples{
data(fishbase)
sex_swap <- which_fish("change sex", using="lifecycle", fish.data)
africa <- which_fish("Africa", using="distribution", fish.data)
fish_names(fish.data[africa & sex_swap])
}

