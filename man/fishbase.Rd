\docType{data}
\name{fishbase}
\alias{fishbase}
\title{Query the XML page of fishbase given a fishbase id
and return the XML R object}
\format{<environment: 0x35ed8e0>}
\usage{
  fishbase
}
\arguments{
  \item{fish.id}{the id number used by fishbase, ranges
  1:70000 though wiht many missing values}

  \item{curl}{curlHandle(), please store value to avoid
  repeated handshaking.}

  \item{server}{the index of the server to use.  1 is
  sinica (Tiawan), 2 is US.}
}
\value{
  a list object with the contents of the major datatypes in
  the the fishbase database.
}
\description{
  Query the XML page of fishbase given a fishbase id and
  return the XML R object
}
\details{
  Typically this function will only be called internally by
  the caching function.
}
\examples{
\dontrun{
  # NileTilapia <- fishbase("2")
}
}
\seealso{
  \code{\link{getData}} and \code{\link{updateCache}}.
}
\keyword{datasets}
\keyword{internal}

