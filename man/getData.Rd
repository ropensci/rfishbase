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

  \item{returns}{a list object with the information for
  those fish, if avaialble.}
}
\description{
  Description: a general function to loop over all fish ids
  to get data also drops the missing entries
}
\details{
  Typically

  this function will only be called internally by the
  caching function.
}
\seealso{
  \code{\link{getData}} and \code{\link{updateCache}}.
}

