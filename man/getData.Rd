\name{getData}
\alias{getData}
\title{Description: a general function to loop over all fish ids to get data
  also drops the missing entries}
\usage{
getData(fish.ids, silent = TRUE)
}
\arguments{
  \item{fish.ids}{used by fishbase. An integer between
  1:70000, though many missing values in between.}

  \item{silent}{a logical of whether to supress warnings.
  default is TRUE}
}
\value{
  a list object with the information for those fish, if
  avaialble.
}
\description{
  Description: a general function to loop over all fish ids
  to get data also drops the missing entries
}
\details{
  Typically this function will only be called internally by
  the caching function.
}
\examples{
\dontrun{
  fish.data <- getData(1:3)
}
}
\seealso{
  \code{\link{getData}} and \code{\link{updateCache}}.
}
\keyword{internal}

