\name{updateCache}
\alias{updateCache}
\title{Update the cached copy of fishbase data}
\usage{
updateCache(path = ".")
}
\arguments{
  \item{path}{where cache should be stored. (default to
  working directory)}
}
\value{
a date-fishdata.Rdat file.
}
\description{
Update the cached copy of fishbase data
}
\details{
the update is slow, avoiding straining the server or
client.  please allow this call to run overnight for a
complete upgrade.
}
\examples{
\dontrun{
 updateCache()
 loadCache()
}
}
\seealso{
\code{\link{loadCache}}
}
\keyword{cache}

