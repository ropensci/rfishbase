\name{updateCache}
\alias{updateCache}
\title{update the cached copy of fishbase data}
\value{
  a date-fishdata.Rdat file in the working directory
}
\description{
  update the cached copy of fishbase data
}
\details{
  the

  update is slow, avoiding straining the server or client.
  please allow this call to run overnight for a complete
  upgrade.
}
\examples{
## not run
#updateCache()
#loadCache()
}
\seealso{
  \code{\link{loadCache}}
}

