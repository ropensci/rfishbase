% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/population_dynamics.R
\name{popgrowth}
\alias{popgrowth}
\title{popgrowth}
\usage{
popgrowth(
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
a table of population growth information by species; see details
}
\description{
This table contains information on growth, natural mortality and length
at first maturity, which serve as inputs to many fish stock assessment
models. The data can also be used to generate empirical relationships
between growth parameters or natural mortality estimates, and their
correlates (e.g., body shape, temperature, etc.), a line of research
that is useful both for stock assessment and for increasing understanding
of the evolution of life-history strategies
}
\examples{
\dontshow{if (interactive()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
\dontrun{
popgrowth("Oreochromis niloticus")
}
\dontshow{\}) # examplesIf}
}
\references{
http://www.fishbase.org/manual/english/fishbasethe_popgrowth_table.htm
}
