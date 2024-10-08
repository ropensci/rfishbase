% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/synonyms.R
\name{synonyms}
\alias{synonyms}
\title{synonyms}
\usage{
synonyms(
  species_list = NULL,
  server = c("fishbase", "sealifebase"),
  version = "latest",
  db = NULL,
  ...
)
}
\arguments{
\item{species_list}{A vector of scientific names (each element as "genus species"). If empty, a table for all fish will be returned.}

\item{server}{Either "fishbase" or "sealifebase".}

\item{version}{a version string for the database. See \code{\link[=available_releases]{available_releases()}} for details.}

\item{db}{database connection, now deprecated.}

\item{...}{additional arguments, currently ignored}
}
\value{
A table with information about the synonym. Will generally be only a single
row if a species name is given.  If a FishBase SpecCode is given, all synonyms matching
that SpecCode are shown, and the table indicates which one is Valid for FishBase. This may
or may not match the valid name for Catalog of Life (Col), also shown in the table. See examples for details.
}
\description{
Check for alternate versions of a scientific name
}
\details{
For further information on fields returned, see:
http://www.fishbase.org/manual/english/fishbasethe_synonyms_table.htm
}
