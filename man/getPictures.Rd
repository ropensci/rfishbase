\name{getPictures}
\alias{getPictures}
\title{getPictures from the fishbase database}
\usage{
  getPictures(genus, species,
    type = c("adult", "juvenile", "larvae", "stamps"),
    what = c("image", "thumbnail", "author"),
    download = FALSE, ...)
}
\arguments{
  \item{genus}{the genus name}

  \item{species}{the species name}

  \item{type}{the kind of photo requested: adult, juvenile,
  larvae, or stamps.}

  \item{what}{character specifying what to return: image
  url, thumbnail, or author name?}

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

