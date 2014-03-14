\name{getFoodItems}
\alias{getFoodItems}
\title{get diet (food items table)}
\usage{
getFoodItems(fish.data = NULL, path = NULL)
}
\arguments{
  \item{fish.data}{the fishbase database fish.data or a
  subset,}

  \item{path}{to cached copy of fishbase (optional,
  defaults to copy in package).}
}
\value{
A list of tables with an entry for each fish in fish.data.
}
\description{
See the "Food Items" page on Fishbase for the species for
details.
}
\details{
See example online table for details:
http://www.fishbase.org/physiology/OxygenDataList.php?ID=2&GenusName=Oreochromis&SpeciesName=niloticus&fc=349&StockCode=1
}
\examples{
\dontrun{
data(fishbase)
getFoodItems(fish.data[1])
}
}

