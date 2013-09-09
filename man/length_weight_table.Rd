\name{length_weight_table}
\alias{length_weight_table}
\title{get length_weight_table}
\usage{
  length_weight_table(fish.data = NULL, path = NULL)
}
\arguments{
  \item{fish.data}{the fishbase database fish.data or a
  subset,}

  \item{path}{to cached copy of fishbase (optional,
  defaults to copy in package).}
}
\value{
  a list of tables for each species given.
}
\description{
  Gets the length_weight table into R.  (e.g. this table:
  http://www.fishbase.org/PopDyn/LWRelationshipList.php?ID=2&GenusName=Oreochromis&SpeciesName=niloticus&fc=349).
}

