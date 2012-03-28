`ro warning=FALSE, message=FALSE, comment=NA, tidy=FALSE, cache=TRUE or`
<!-- 
  Uses PANDOC style citations 
  filename_pandoc_.markdown is the pandoc source file. 
  It requires the html-comment style  knitr blocks to avoid conflict with pandoc. 
  You can generate a markdown file with citations inserted using the Makefile or using:
  pandoc -s -S --biblio rfishbase.bib rfishbase_pandoc_.markdown -o rfishbase_pandoc.md
  knitr can then operate smoothly on the .md output
-->
*This is a work in progress*

% Rfishbase
% Carl Boettiger[^\*][^a] and Peter Wainwright[^a]
% 

[^a]: Center for Population Biology, University of California, Davis, United  States
  

# Abstract 
We introduce a package that provides interactive and programmatic
access to the FishBase repository. This package allows us to
interact with data on over 30,000 fish species in the rich
statistical computing environment, `R`. We illustrate how this
direct, scriptable interface to FishBase data enables better
discovery and integration essential for large-scale comparative
analyses. We provide several examples to illustrate how the package
works, and how it can be integrated into such as phylogenetics
packages `ape` and `geiger`.


###### keywords 
R | vignette | fishbase

# Introduction


<!--begin.rcode libraries, echo=FALSE
library(rfishbase) 
library(xtable) 
library(ggplot2)
data(fishbase)
end.rcode-->


Informatics
Stuff about Machine access to data, role of large scale data in ecology [@jones2006d], [@hanson2011a], [@reichman2011a]

FishBase ([fishbase.org](http://fishbase.org)) is an award-winning
online database of information about the morphology, trophic ecology,
physiology, ecotoxicology, reproduction, economic relevance of the
world’s fish, organized by species [@fishbase2012]. FishBase was developed in
collaboration with the United Nations Food and Agriculture Organization
and is supported by a consortium of nine research institutions. In
addition to its web-based interface, FishBase provides machine readable
XML files for <!--rinline I(sprintf("%d", length(fish.data))) --> of its species entries.

To facilitate the extraction, visualization, and integration of this
data in research, we have written the `rfishbase` package for the R
language for statistical computing and graphics [@rteam2012]. R is a freely
available open source computing environment that is used extensively in
ecological research, with a large library of packages built explicitly
for this purpose [@kneib2007].



# A programmatic interface

The `rfishbase` package works by creating a cached copy of all data on
fishbase currently available in XML format. Caching increases the speed
of queries and places minimal demands on the fishbase server, which in
it’s present form is not built to support direct access to application
programming interfaces (APIs). The cached copy can be loaded in to R
using the command:

<!--begin.rcode loaddata
data(fishbase) 
end.rcode-->

To get the most recent copy of fishbase, update the cache instead. The
update may take up to 24 hours. This copy is stored in the working
directory with the current date and can be loaded when finished.

<!--begin.rcode update, eval=FALSE
updateCache()
loadCache("2012-03-26fishdata.Rdat")
end.rcode-->
Loading the database creates an object called fish.data, with one entry
per fish species for which data was successfully found, for a total of
<!--rinline I(sprintf("%d", length(fish.data))) --> species.  

# Data extraction, analysis, and visualization

Comparative studies

The examples we give here are meant to be illustrative of the kinds of
queries that are possible, and also provide a simple introduction to
assist the reader in using the software itself.

Quantitatve queries 

<!--begin.rcode AgeHist
yr <- getSize(fish.data, "age")
end.rcode-->

Identify fish with mention of noturnal behavior in the their trophic description.

<!--begin.rcode nocturnal
nocturnal <- which_fish("nocturnal", "trophic", fish.data)
end.rcode-->

The object returned is a list of true/false values,
indicating all fish in the dataset that match this query. This format is
useful because it allows us to subset the original data and pass it to
another query. For instance, we can use the `fish_names` function to
return the names of these fish. `fish_names` can return more than just
species names – here we ask it to give us the top taxonomic Orders of
these nocturnal fish, organized into a table:

<!--begin.rcode nocturnal_table
nocturnal_orders <-fish_names(fish.data[nocturnal], "Order") 
xtable(table(nocturnal_orders))
end.rcode-->

The real power of programatic access the ease with which we can combine,
visualize, and statistically test a custom compilation of this data. We
begin by generating a custom data table of characteristics of interest


<!--begin.rcode fishdataframe
reef <- which_fish("reef", "habitat", fish.data)
nocturnal <- which_fish("nocturnal", "trophic", fish.data)
marine <- which_fish("marine", "habitat", fish.data)
africa <- which_fish("Africa:", "distribution", fish.data)
age <- getSize(fish.data, "age")
length <- getSize(fish.data, "length")
order <- fish_names(fish.data, "Order")
dat <- data.frame(reef, nocturnal,  marine,  africa, age, length, order)
end.rcode-->

This data frame contains categorical data (*e.g.* is the fish a
carnivore) and continuous data (*e.g.* weight or age of fish). We can
take advantage of the rich data visualization in R to begin exploring
this data.

<!--begin.rcode dataplots, fig.width=10
ggplot(dat,aes(age, length, color=marine)) + geom_point(position='jitter',alpha=.8) + scale_y_log10() + scale_x_log10() 
end.rcode-->

More nocturnal species are found on reefs than non-reefs

<!--begin.rcode 
qplot(reef[nocturnal])
end.rcode-->

Are reef species longer lived than non-reef species in the marine environment?

<!--begin.rcode  
ggplot(subset(dat, marine),aes(reef, log(age))) + geom_boxplot() 
end.rcode-->

Fraction of marine species found in the 10 largest orders

<!--begin.rcode fraction_marine
biggest <- names(head(sort(table(order),decr=T), 10))
ggplot(subset(dat,order %in% biggest), aes(order, fill=marine)) + geom_bar() 
end.rcode-->


Typical use of the package involves constructing queries to identify
species matching certain criteria. The powerful R interface makes it
easy to combine queries in complex ways to answer particular questions.
For instance, we can ask "are there more labrids or goby species of reef
fish?" using the following queries:

Get all species in fishbase from the families "Labridae" (wrasses) or
"Scaridae" (parrotfishes):

<!--begin.rcode labrid
labrid <- familySearch("(Labridae|Scaridae)", fish.data)
end.rcode-->

and get all the species of gobies

<!--begin.rcode gobycoount
goby <- familySearch("Gobiidae", fish.data)
end.rcode-->

Identify how many labrids are found on reefs

<!--begin.rcode labridreef
labrid.reef <- habitatSearch("reef", fish.data[labrid])
nlabrids <- sum(labrid.reef)
end.rcode-->

and how many gobies are found on reefs:

<!--begin.rcode gobyreef
ngobies <- sum (habitatSearch("reef", fish.data[goby]) )
end.rcode-->

showing us that there are <!--rinline I(nlabrids) --> labrid species associated with reefs,
and <!--rinline I(ngobies) --> goby species associated with reefs.  




Note that any function can take a subset of the data, as specified by
the square brackets.

# Integration of analyses

One of the greatest advantages about accessing FishBase directly through
R is the ability to take advantage of the suite of specialized analyses
available through R packages. Likewise, users familiar with these
packages can more easily take advantage of the data available on
fishbase. We illustrate this with an example that combines phylogenetic
methods available in R with quantitative trait data available from
`rfishbase`.

This series of commands illustrates testing for a phylogenetically
corrected correlation between the maximum observed size of a species and
the maximum observed depth at which it is found.


load a phylogenetic tree and some phylogenetics packages
<!--begin.rcode results="hide", message=FALSE
data(labridtree)
require(geiger) 
end.rcode-->

 Find those species on FishBase 
<!--begin.rcode 
myfish <- findSpecies(tree$tip.label, fish.data)
end.rcode-->

Get the maxium depth of each species and sizes of each species: 
<!--begin.rcode  
depths <- getDepth(fish.data[myfish])[,"deep"]
size <- getSize(fish.data[myfish], "length")
end.rcode-->

Drop tips from the phylogeny for unmatched species.  
<!--begin.rcode  
data <- na.omit(data.frame(size,depths))
pruned <- treedata(tree, data)
end.rcode-->


Use phylogenetically independent contrasts [@felsenstein1985] to determine if depth correlates with size after correcting for phylogeny:

<!--begin.rcode 
x <- pic(pruned$data[["size"]],pruned$phy)
y <- pic(pruned$data[["depths"]],pruned$phy)
xtable(summary(lm(y ~ x - 1)))
ggplot(data.frame(x=x,y=y), aes(x,y)) + geom_point() + stat_smooth(method=lm)
end.rcode-->

We can also estimate different evolutionary models for these traits to decide which best describes the data,

<!--begin.rcode models, results="hide"
bm <- fitContinuous(pruned$phy, pruned$data[["depths"]], model="BM")[[1]]
ou <- fitContinuous(pruned$phy, pruned$data[["depths"]], model="OU")[[1]]
end.rcode-->

where the Brownian motion model has an AIC score of <!--rinline I(bm$aic) --> while
the OU model has a score
of <!--rinline I(ou$aic) -->, suggesting that <!--rinline I(names(which.min(list(BM=bm$aic,OU=ou$aic)))) --> is the better model.

In a similar fashion, programmers of other R software packages can make
use of the rfishbase package to make this data available to their
functions, further increasing the use and impact of fishbase. For
instance, the project OpenFisheries.org makes use of the fishbase
package to provide information about commercially relevant species.

# Discussion

## The self-updating study

Describe how this package could help make studies that could be
automatically updated as the dataset is improved and expanded (like the
examples in this document which are automatically run when the pdf is
created). 
[@peng2011b; @merali2010].


## Limitations and future directions

Fishbase contains much additional data that has not been made accessible
in it’s machine-readable XML format. We are in contact with the database
managers and look forward to providing access to additional types of
data as they become available.

# Acknowledgements

CB is supported by a Computational Sciences Graduate Fellowship from the
Department of Energy under grant number DE-FG02-97ER25308.


[^\*]: Corresponding author <cboettig@ucdavis.edu> 


# References

