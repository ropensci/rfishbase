\name{fishbase}
\alias{fishbase}
\title{Query the XML page of fishbase given a fishbase id
and return the XML R object}
\usage{
  fishbase(fish.id, curl = getCurlHandle())
}
\arguments{
  \item{fish.id:}{the id number used by fishbase, ranges
  1:70000 though wiht many missing values}
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
  Typically

  this function will only be called internally by the
  caching function.
}
\examples{
NileTilapia <- fishbase("2")
}
\seealso{
  \code{\link{getData}} and \code{\link{updateCache}}.
}

