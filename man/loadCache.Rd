\name{loadCache}
\alias{loadCache}
\title{loads an updated cache by the date}
\usage{
  loadCache(date = Sys.Date())
}
\arguments{
  \item{date}{the date of the cache to be loaded, in
  yyyy-mm-dd format.}
}
\value{
  loads the object fish.data into the working space.
}
\description{
  loads an updated cache by the date
}
\examples{
\dontrun{
updateCache()
loadCache()
}
}
\seealso{
  \code{\link{updateCache}}
}
\keyword{cache}

