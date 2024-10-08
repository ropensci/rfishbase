% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/common_names.R
\name{common_to_sci}
\alias{common_to_sci}
\title{common_to_sci}
\usage{
common_to_sci(
  x,
  Language = "English",
  server = c("fishbase", "sealifebase"),
  version = "latest",
  db = NULL
)
}
\arguments{
\item{x}{a common name or list of common names}

\item{Language}{a string specifying the language for the common name, e.g. "English"}

\item{server}{Either "fishbase" or "sealifebase".}

\item{version}{a version string for the database. See \code{\link[=available_releases]{available_releases()}} for details.}

\item{db}{database connection, now deprecated.}
}
\value{
a character vector of scientific names
}
\description{
Return a list of scientific names corresponding to given the common name(s).
}
\details{
If more than one scientific name matches the common name (e.g. "trout"), the function
will simply return a list of all matching scientific names.  If given more than one common name,
the resulting strings of matching scientific names are simply concatenated.
}
\examples{
\dontshow{if (interactive()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
\donttest{
common_to_sci(c("Bicolor cleaner wrasse", "humphead parrotfish"), Language="English")
common_to_sci(c("Coho Salmon", "trout"))
}
\dontshow{\}) # examplesIf}
}
\seealso{
\code{\link{synonyms}}
}
