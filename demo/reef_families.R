# Author: Carl Boettiger
# Date 11 Feburary 2012
# Script: reef_families.R
#
# License: CC0 
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain 
# worldwide. This software is distributed without any warranty.  
# For a copy of the CC0 Public Domain Dedication along with this software. 
# see <http://creativecommons.org/publicdomain/zero/1.0/>.
# 
#
# Description: A demonstration that gets every family of fish in fishbase
# and calculates the number of species in that family that are reef and 
# non-reef.  Returns a table with families as rows and columns listing
# the fraction of reef species, total number of reef and total # of species
#
# Details: Reef species are defined as matches of reef to the habitat 
# description provided by fishbase
#

## Load package and data (install if necessary by uncommenting the line below)
#install.packages(c("rfishbase", "plyr"))
library(rfishbase)
data(fishbase)

# Get a list of all families in fishbase
family_list <- sapply(fish.data, function(x) x$Family)
families <- unique(family_list)

library(plyr) #  A package to reformat the data nicely

# Compute the fraction of reef species for each family
results <- ldply(families, function(f){
  group <- familySearch(f, fish.data)
  reef <- habitatSearch("reef", fish.data[group])
  reef_no <- sum(reef)
  total <- sum(group)
  c(family=f, fraction=reef_no/total, reef=reef_no, total=total)
})

write.csv(results, file="reef_families.csv", quote=FALSE)
