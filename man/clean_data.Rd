\name{clean_data}
\alias{clean_data}
\title{clean the fish.base data into pure ASCII}
\usage{
  clean_data(fish.data)
}
\arguments{
  \item{a}{list item with fishbase data}
}
\value{
  the item scrubbed of non-ASCII characters
}
\description{
  clean the fish.base data into pure ASCII
}
\examples{
\dontrun{
 data(fishbase)
 fish.data <- clean_data(fish.data)
}
}
\keyword{internal}

