\name{getTrophicLevel}
\alias{getTrophicLevel}
\title{get trophic level}
\usage{
getTrophicLevel(fish.data = NULL, path = NULL, as_table = FALSE,
  from = c("diet composition", "individual food items"), unfished = FALSE,
  justSE = FALSE, justReference = FALSE)
}
\arguments{
  \item{fish.data}{the fishbase database fish.data or a
  subset,}

  \item{path}{to cached copy of fishbase (optional,
  defaults to copy in package).}

  \item{as_table}{logical. if True, returns the whole
  table.  Otherwise (default), returns the element from the
  table that is specified by the other options.}

  \item{from}{use the diet composition or the individual
  food items?  See fishbase.org for details on these
  differences.  Both may or may not be available.}

  \item{unfished}{return the estimate for unfished
  population (default FALSE).  See fishbase.org for
  details.}

  \item{justSE}{return the standard deviation to the
  estimated trophic level.  If FALSE, returns the estimated
  value, so you must use two calls, or use as_table=TRUE,
  to get both values.}

  \item{justReference}{logical. return the reference used
  for estimation (without other data).}
}
\value{
depends on the arguments given above.  Default is to return
the (fished) diet composition estimate (often used as the
default in fishbase.org).
}
\description{
get a quantitative estimate of the trophic level for the
species requested. See the "Ecology" page on Fishbase for
the speices.
}

