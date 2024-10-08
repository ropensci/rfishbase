% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/trophic_ecology.R
\name{ration}
\alias{ration}
\title{ration}
\usage{
ration(
  species_list = NULL,
  fields = NULL,
  server = c("fishbase", "sealifebase"),
  version = "latest",
  db = NULL,
  ...
)
}
\arguments{
\item{species_list}{A vector of scientific names (each element as "genus species"). If empty, a table for all fish will be returned.}

\item{fields}{subset to these columns.  (recommend to omit this and handle manually)}

\item{server}{Either "fishbase" or "sealifebase".}

\item{version}{a version string for the database. See \code{\link[=available_releases]{available_releases()}} for details.}

\item{db}{database connection, now deprecated.}

\item{...}{additional arguments, currently ignored}
}
\value{
a table of species ration
}
\description{
ration
}
\examples{
\dontshow{if (interactive()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
\dontrun{
ration("Oreochromis niloticus")
}
\dontshow{\}) # examplesIf}
}
\references{
http://www.fishbase.org/manual/english/fishbasethe_ration_table.htm
}
