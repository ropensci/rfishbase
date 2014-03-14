\name{getPictures}
\alias{getPictures}
\title{getPictures from the fishbase database}
\usage{
getPictures(scientific_name, type = c("adult", "juvenile", "larvae",
  "stamps"), what = c("actual", "thumbnail", "author"), download = FALSE,
  ...)
}
\arguments{
  \item{scientific_name}{the space-separated genus and
  species names}

  \item{type}{the kind of photo requested: adult, juvenile,
  larvae, or stamps.}

  \item{what}{character specifying what to return: actual
  image, thumbnail, or author name?}

  \item{download}{logical, download to working directory?}

  \item{...}{additional options to download.file}
}
\value{
list of image urls.  If download=TRUE, will also dowload
images to working directory.
}
\description{
get urls of fishbase images given a genus and species
}

