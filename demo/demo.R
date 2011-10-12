# demo.R
rm(list=ls())
require(rfishbase)

###### Grabbing, Loading & Caching Fishbase Data ######

## Download and parse data for first 40 ids (36 fish)
#fish.data <- getData(1:40)

## Or just load the cached copy of the full fishbase data:
## Note that this loads the copy distributed with rfishbase.
data(fishbase)

## To get the most recent copy of fishbase, update the cache
## and load that.  The update may take up to 24 hours.  
# updateCache() 
# loadCache("2011-10-12fishdata.Rdat")


###### Sample Analysis #########

## Lets start by looking at the distribution of all age data available:
yr <- getSize(all.fishbase, "age")
hist(yr, breaks=40, main="Age Distribution", xlab="age (years)"); 
nfish <- length(all.fishbase)


# We can create partitions by taxon.  For instance, we get the index
# to all fish wrasses and parrotfish by searching for both families
# note the use of a "regular expression" to specify the OR command in the search
labrid <- familySearch("(Labridae|Scaridae)", all.fishbase)
goby <- familySearch("Gobiidae", all.fishbase)


## Let's see if there are more labrid species or goby speices on reefs:

# get all the labrids that are reefs 
labrid.reef <- habitatSearch("reef", all.fishbase[labrid])
# How many species are reef labrids:
sum(labrid.reef) # same as: length(all.fishbase[labrid][labrid.reef])
# How many reef gobies:
sum (habitatSearch("reef", all.fishbase[goby]) )


# Let's plot the log length distribution of freshwater vs marine fish: 
hist(log( getSize (all.fishbase[habitatSearch("freshwater", all.fishbase)], "length")),
         col=rgb(1,0,0,.5), breaks=40, freq=F, xlab="length", main="marine fish are bigger")
hist(log( getSize (all.fishbase[habitatSearch("marine", all.fishbase)], "length")),
          col=rgb(0,0,1,.5), breaks=40, add=T, freq=F)

# Note that we can also find anadromous fish:
anadromous <-  habitatSearch("anadromous", all.fishbase)



# this is useful for phylogenetic comparative methods.  For instance, load the labrid tree:
require(ape)
data(labridtree)

# get the species names (& remove underscores)
tree$tip.label<-gsub("_", " ", tree$tip.label)
tip.labels <- tree$tip.label


myfish <- findSpecies(tip.labels, all.fishbase) 
species.names <- sapply(all.fishbase[myfish], function(x) x$ScientificName)

# create a trait matrix of fin data
traits <- getQuantTraits(all.fishbase[myfish])
rownames(traits) <- species.names
depths <- getDepth(all.fishbase[myfish])
rownames(depths) <- species.names

size <- getSize(all.fishbase[myfish], "length")
names(size) <- species.names

# who's missing from treebase entirely?
missing<-tip.labels[! tip.labels %in% species.names ]
tr<- drop.tip(tree, missing)
# drop species with NAs for max depth
depth <- depths[,2]
missing<-names(depth[is.na(depth)])
tr<- drop.tip(tr, missing)
# repeat for NAs for length
missing<-names(size[is.na(size)])
tr<- drop.tip(tr, missing)

# drop all the data not in the tree 
pruned.names <- tr$tip.label
size <- size[pruned.names]
depth <- depth[pruned.names]

# Does depth correlate with size after correcting for phylogeny?
x <- pic(size, tr)
y <- pic(depth, tr)
summary(lm(y~x-1)) # Yes


require(geiger)
bm <- fitContinuous(tr, depth, model="BM")
ou <- fitContinuous(tr, depth, model="OU")


invert <- sapply(all.fishbase, function(x) length(grep("invertebrate", x$trophic))>0)
piscivore <- sapply(all.fishbase, function(x) length(grep("(piscivore|fish)", x$trophic))>0)
hist(log( getSize (all.fishbase[invert], "length")),
         col=rgb(1,0,0,.5), breaks=40, freq=F, xlab="length", main="invert eaters vs piscivores")
hist(log( getSize (all.fishbase[piscivore], "length")),
          col=rgb(0,0,1,.5), breaks=40, add=T, freq=F)





## Using a treebase tree
require(rtreebase)
fish <- all.fishbase[[2]]$ScientificName
trees <- search_treebase(paste("%22", fish, "%22", sep=""), by="taxon", branch=TRUE)
str <- trees[[1]]$tip.label
gsub("(\\w+)_(\\w+)_.*", "\\1 \\2", str)
myfish <- findSpecies(species, all.fishbase) 
getQuantTraits(all.fishbase[myfish])



