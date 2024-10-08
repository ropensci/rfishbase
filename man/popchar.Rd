% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/population_dynamics.R
\name{popchar}
\alias{popchar}
\title{popchar}
\usage{
popchar(
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
\description{
Table of maximum length (Lmax), weight (Wmax) and age (tmax)
}
\details{
See references for official documentation.  From FishBase.org:
This table presents information on maximum length (Lmax),
weight (Wmax) and age (tmax) from various localities where a species
occurs. The largest values from this table are also entered in the
SPECIES table. The POPCHAR table also indicates whether the Lmax,
Wmax and tmax values or various combinations thereof refer to the
same individual fish.
}
\examples{
\dontshow{if (interactive()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
\dontrun{
popchar("Oreochromis niloticus")
}
\dontshow{\}) # examplesIf}
}
\references{
http://www.fishbase.org/manual/english/fishbasethe_popchar_table.htm
}
