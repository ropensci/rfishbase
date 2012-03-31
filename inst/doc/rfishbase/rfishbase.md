

% Rfishbase
% Carl Boettiger; Peter Wainwright
% March 28, 2012

Center for Population Biology, University of California, Davis, United  States

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




```
Error: there is no package called 'xtable'
```





FishBase ([fishbase.org](http://fishbase.org)) is an award-winning
online database of information about the morphology, trophic ecology,
physiology, ecotoxicology, reproduction, economic relevance of the
world’s fish, organized by species [@fishbase2012]. FishBase was developed in
collaboration with the United Nations Food and Agriculture Organization
and is supported by a consortium of nine research institutions. In
addition to its web-based interface, FishBase provides machine readable
XML files for `30622` of its species entries.

To facilitate the extraction, visualization, and integration of this
data in research, we have written the `rfishbase` package for the R
language for statistical computing and graphics [@rteam2012]. R is a freely
available open source computing environment that is used extensively in
ecological research, with a large library of packages built explicitly
for this purpose [@kneib2007].  

In this paper, we illustrate how the `rfishbase` package is synchronized 
with the FishBase database, describe its functions for extracting, 
manipulating and visualizing data, and then illustrate how these 
functions can be combined for more complicated analyses.  Lastly we 
illustrate how having access to FishBase data through R allows 
a user to interface with other kinds of analyses, such as 
comparative phylogenetics software.  


# A programmatic interface

The `rfishbase` package works by creating a cached copy of all data on
FishBase currently available in XML format. Caching increases the speed
of queries and places minimal demands on the FishBase server, which in
its present form is not built to support direct access to application
programming interfaces (APIs). A cached copy is included in the package 
and can be loaded in to R using the command:



```r
data(fishbase)
```




This loads a copy of all available data from FishBase into the R list, 
`fish.data`, which can be passed to the various functions of `rfishbase`
to extraction, manipulation and visualization.  The online repository
is frequently updated as new information is uploaded.  To get the most 
recent copy of FishBase, update the cache instead. The
update may take up to 24 hours. This copy is stored in the working
directory with the current date and can be loaded when finished.



```r
updateCache()
loadCache("2012-03-26fishdata.Rdat")
```



Loading the database creates an object called fish.data, with one entry
per fish species for which data was successfully found, for a total of
`30622` species.  

Not all the data available in FishBase is included in these machine-readable 
XML files.  Consequently, `rfishbase` returns taxonomic information, trophic
description, habitat, distribution, size, life-cycle, morphology and diagnostic
information.  The information returned in each category is provided as plain-text,
consequently `rfishbase` must use regular expression matching to identify
the occurrence of particular words or patterns in this text corresponding to 
data of interest. 

Quantitative traits such as length, maximum known age, spine and ray counts,
and depth information are provided consistently for most species, allowing 
`rfishbase` to extract this data directly.  Other queries require pattern matching.
While simple text searches within a given field are usually reliable, the 
`rfishbase` search functions will take any regular expression query, which
permits logical matching, identification of number strings, and much more.
The interested user should consult a reference on regular expressions after
studying the simple examples provided here to learn more.  

# Data extraction, analysis, and visualization

The basic function data extraction function in `rfishbase` is `which_fish()`. 
The function takes a list of fishbase data (usually the entire database, `fish.data`,
or a subset thereof, as illustrated later) and returns an array of those
species matching the query.  This array is given as a list of true/false values
for every species in the query.  This return structure has several advantages which
we illustrate by example.  

Here is a query for reef-associated fish (mention of "reef" in the habitat description),
and second query for fish that have "nocturnal" in their trophic description:



```r
reef <- which_fish("reef", "habitat", fish.data)
nocturnal <- which_fish("nocturnal", "trophic", 
    fish.data)
```



One way these returned values are commonly used is to obtain a subset of the 
database that meets this criteria, which can then be passed on to other functions.
For instance, if we want the scientific names of these reef fish, we use the 
`fish_names` function.  Like the `which_fish` function, it takes the database 
of fish, `fish.data` as input.  In this case, we pass it just the subset that are 
reef affiliated,



```r
reef_species <- fish_names(fish.data[reef])
```




Because our `reef` object is a list of logical values (true/false), we can
combine this in intuitive ways with other queries.  For instance, give us the 
names for all fish that are nocturnal and not reef associated,



```r
nocturnal_nonreef_orders <- fish_names(fish.data[nocturnal & 
    !reef], "Class")
```




Note that this time we have also specified that we want taxanomic Class
of the fish matching the query, rather than the species names.  `fish_names`
will allow us to specify any taxanomic level for it to return.

Quantitative trait queries work like `fish_names`, taking a the FishBase 
data and returning the requested information.  For instance, the function
`getSize` returns the length (default), weight, or age of the fish in the query:



```r
age <- getSize(fish.data, "age")
```



```
Error: 'names' attribute [3] must be the same length as the vector [0]
```




`rfishbase` can also extract a table of quantitative traits from the morphology field,
describing the number of vertebrate, dorsal and anal rays and spines,



```r
morphology_numbers <- getQuantTraits(fish.data)
```




and extract the depth range (extremes and usual range) from the habitat field,

``` { r depths}
depths <- getDepth(fish.data)




The real power of programatic access the ease with which we can combine,
visualize, and statistically test a custom compilation of this data. 
To do so it is useful to organize a collection of queries into a data frame.
Here we combine the queries we have made above and a few additional queries
into a data frame in which each row represents a species and each column
represents a variable.  




```r
marine <- which_fish("marine", "habitat", fish.data)
africa <- which_fish("Africa:", "distribution", 
    fish.data)
length <- getSize(fish.data, "length")
```



```
Error: 'names' attribute [3] must be the same length as the vector [0]
```



```r
order <- fish_names(fish.data, "Order")
dat <- data.frame(reef, nocturnal, age, marine, 
    africa, length, order)
```



```
Error: object 'age' not found
```




This data frame contains categorical data (*e.g.* is the fish a
carnivore) and continuous data (*e.g.* weight or age of fish). We can
take advantage of the rich data visualization in R to begin exploring
this data.  These examples are simply meant to be illustrative of the 
kinds of analysis possible and how they would be constructed.  

Fraction of marine species found in the 10 largest orders



```r
biggest <- names(head(sort(table(order), decr = T), 
    10))
ggplot(subset(dat, order %in% biggest), aes(order, 
    fill = marine)) + geom_bar()
```



```
Error: object 'dat' not found
```




Is age correlated with size?



```r
ggplot(dat, aes(age, length, color = marine)) + 
    geom_point(position = "jitter", alpha = 0.8) + scale_y_log10() + 
    scale_x_log10()
```



```
Error: object 'dat' not found
```




A statistical test of this pattern: 



```r
xtable(summary(lm(data = dat, log(length) ~ log(age))))
```



```
Error: could not find function "xtable"
```





Are reef species longer lived than non-reef species in the marine environment?



```r
ggplot(subset(dat, marine), aes(reef, log(age))) + 
    geom_boxplot()
```



```
Error: object 'dat' not found
```




## Comparative studies
Many ecological and evolutionary studies rely on comparisons between
taxa to pursue questions that cannot be approached experimentally.  
Instead, we rely on evolution to have performed the experiment already.
For instance, recent studies have attempted to identify whether 
reef-associated clades experience greater species diversification rates
than non-reef-associated groups [*e.g.* @Alfaro2009a].  We can easily
identify and compare the numbers of reef associated species in different
families using the `rfishbase` functions presented above.  

In this example, we answer the simpler question "Are there more reef-associated
species in labrids than in gobies?

Get all species in fishbase from the families "Labridae" (wrasses) or
"Scaridae" (parrotfishes):



```r
labrid <- which_fish("(Labridae|Scaridae)", "Family", 
    fish.data)
```



```
Error: 'arg' should be one of "trophic", "habitat", "lifecycle", "morphology", "diagnostic", "distribution"
```




and get all the species of gobies



```r
goby <- which_fish("Gobiidae", "Family", fish.data)
```



```
Error: 'arg' should be one of "trophic", "habitat", "lifecycle", "morphology", "diagnostic", "distribution"
```




Identify how many labrids are found on reefs



```r
labrid.reef <- which_fish("reef", "habitat", fish.data[labrid])
```



```
Error: object 'labrid' not found
```



```r
nlabrids <- sum(labrid.reef)
```



```
Error: object 'labrid.reef' not found
```




and how many gobies are found on reefs:



```r
ngobies <- sum(which_fish("reef", "habitat", fish.data[goby]))
```



```
Error: object 'goby' not found
```




Note that summing the list of true/false values returned gives the total number of matches.  
This tells us that there are 

```

Error in unique(c("AsIs", oldClass(x))) : object 'nlabrids' not found

```

 labrid species associated with reefs,
and 

```

Error in unique(c("AsIs", oldClass(x))) : object 'ngobies' not found

```

 goby species associated with reefs.  


# Integration of analyses

One of the greatest advantages about accessing FishBase directly through
R is the ability to take advantage of the suite of specialized analyses
available through R packages. Likewise, users familiar with these
packages can more easily take advantage of the data available on
FishBase. We illustrate this with an example that combines phylogenetic
methods available in R with quantitative trait data available from
`rfishbase`.



This series of commands illustrates testing for a phylogenetically
corrected correlation between the maximum observed size of a species and
the maximum observed depth at which it is found.


load a phylogenetic tree and some phylogenetics packages



```r
data(labridtree)
require(geiger)
```




 Find those species on FishBase 



```r
myfish <- findSpecies(tree$tip.label, fish.data)
```




Get the maximum depth of each species and sizes of each species: 



```r
depths <- getDepth(fish.data[myfish])[, "deep"]
size <- getSize(fish.data[myfish], "length")
```




Drop tips from the phylogeny for unmatched species.  



```r
data <- na.omit(data.frame(size, depths))
pruned <- treedata(tree, data)
```



```
Dropped tips from the tree because there were no matching names in the data:
  [1] "Anampses_caeruleopunctatus"   "Anampses_geographicus"       
  [3] "Anampses_meleagrides"         "Anampses_neoguinaicus"       
  [5] "Bodianus_mesothorax"          "Bodianus_perditio"           
  [7] "Bodianus_rufus"               "Bolbometopon_muricatum"      
  [9] "Calotomus_spinidens"          "Cetoscarus_bicolor"          
 [11] "Cheilinus_chlorourus"         "Cheilinus_fasciatus"         
 [13] "Cheilinus_oxycephalus"        "Cheilinus_trilobatus"        
 [15] "Cheilinus_undulatus"          "Cheilio_inermis"             
 [17] "Chlorurus_bleekeri"           "Chlorurus_microrhinos"       
 [19] "Chlorurus_sordidus"           "Choerodon_anchorago"         
 [21] "Choerodon_cephalotes"         "Choerodon_fasciatus"         
 [23] "Choerodon_schoenleinii"       "Choerodon_venustus"          
 [25] "Clepticus_parrae"             "Coris_aygula"                
 [27] "Coris_batuensis"              "Coris_dorsomacula"           
 [29] "Coris_gaimard"                "Coris_pictoides"             
 [31] "Cryptotomus_roseus"           "Cymolutes_praetextatus"      
 [33] "Cymolutes_torquatus"          "Diproctacanthus_xanthurus"   
 [35] "Epibulus_insidiator"          "Gomphosus_varius"            
 [37] "Halichoeres_biocellatus"      "Halichoeres_bivittatus"      
 [39] "Halichoeres_chloropterus"     "Halichoeres_chrysus"         
 [41] "Halichoeres_garnoti"          "Halichoeres_hortulanus"      
 [43] "Halichoeres_maculipinna"      "Halichoeres_margaritaceus"   
 [45] "Halichoeres_marginatus"       "Halichoeres_melanurus"       
 [47] "Halichoeres_miniatus"         "Halichoeres_nebulosus"       
 [49] "Halichoeres_nigrescens"       "Halichoeres_ornatissimus"    
 [51] "Halichoeres_pictus"           "Halichoeres_poeyi"           
 [53] "Halichoeres_prosopeion"       "Halichoeres_radiatus"        
 [55] "Halichoeres_scapularis"       "Halichoeres_trimaculatus"    
 [57] "Hemigymnus_melapterus"        "Hipposcarus_longiceps"       
 [59] "Hologymnosus_annulatus"       "Hologymnosus_doliatus"       
 [61] "Labrichthys_unilineatus"      "Labroides_bicolor"           
 [63] "Labroides_dimidiatus"         "Labropsis_australis"         
 [65] "Lachnolaimus_maximus"         "Leptojulis_cyanopleura"      
 [67] "Macropharyngodon_choati"      "Macropharyngodon_kuiteri"    
 [69] "Macropharyngodon_meleagris"   "Macropharyngodon_negrosensis"
 [71] "Novaculichthys_taeniourus"    "Oxycheilinus_bimaculatus"    
 [73] "Oxycheilinus_digrammus"       "Oxycheilinus_unifasciatus"   
 [75] "Pseudocheilinus_octotaenia"   "Pseudocoris_yamashiroi"      
 [77] "Pseudodax_moluccanus"         "Pseudojuloides_cerasinus"    
 [79] "Pseudolabrus_guentheri"       "Pteragogus_cryptus"          
 [81] "Scarus_altipinnis"            "Scarus_chameleon"            
 [83] "Scarus_dimidiatus"            "Scarus_flavipectoralis"      
 [85] "Scarus_frenatus"              "Scarus_ghobban"              
 [87] "Scarus_globiceps"             "Scarus_iseri"                
 [89] "Scarus_niger"                 "Scarus_oviceps"              
 [91] "Scarus_psittacus"             "Scarus_rivulatus"            
 [93] "Scarus_schlegeli"             "Scarus_spinus"               
 [95] "Scarus_taeniopterus"          "Sparisoma_atomarium"         
 [97] "Sparisoma_aurofrenatum"       "Sparisoma_chrysopterum"      
 [99] "Sparisoma_radians"            "Sparisoma_rubripinne"        
[101] "Sparisoma_viride"             "Stethojulis_bandanensis"     
[103] "Stethojulis_trilineata"       "Thalassoma_amblycephalum"    
[105] "Thalassoma_bifasciatum"       "Thalassoma_hardwicke"        
[107] "Thalassoma_jansenii"          "Thalassoma_lunare"           
[109] "Thalassoma_lutescens"         "Thalassoma_quinquevittatum"  
[111] "Thalassoma_trilobatum"        "Wetmorella_nigropinnata"     
[113] "Xyrichtys_martinicensis"      "Xyrichtys_novacula"          

Dropped rows from the data because there were no matching tips in the tree:
  [1] "1"   "10"  "100" "101" "103" "105" "106" "109" "11"  "110" "113"
 [12] "12"  "13"  "14"  "15"  "16"  "17"  "18"  "19"  "2"   "20"  "21" 
 [23] "22"  "23"  "24"  "26"  "27"  "28"  "29"  "3"   "30"  "31"  "32" 
 [34] "36"  "37"  "38"  "39"  "4"   "41"  "42"  "43"  "45"  "46"  "47" 
 [45] "48"  "49"  "5"   "50"  "51"  "52"  "53"  "54"  "55"  "56"  "57" 
 [56] "58"  "59"  "6"   "60"  "61"  "62"  "63"  "64"  "65"  "66"  "67" 
 [67] "68"  "69"  "7"   "70"  "71"  "72"  "73"  "74"  "75"  "76"  "77" 
 [78] "78"  "79"  "8"   "80"  "81"  "82"  "83"  "84"  "85"  "86"  "87" 
 [89] "88"  "89"  "9"   "90"  "91"  "92"  "93"  "94"  "95"  "96"  "98" 
[100] "99" 

```





Use phylogenetically independent contrasts [@felsenstein1985] to 
determine if depth correlates with size after correcting for phylogeny:



```r
x <- pic(pruned$data[["size"]], pruned$phy)
```



```
Error: 'phy' is not rooted and fully dichotomous
```



```r
y <- pic(pruned$data[["depths"]], pruned$phy)
```



```
Error: 'phy' is not rooted and fully dichotomous
```



```r
xtable(summary(lm(y ~ x - 1)))
```



```
Error: could not find function "xtable"
```



```r
ggplot(data.frame(x = x, y = y), aes(x, y)) + 
    geom_point() + stat_smooth(method = lm)
```



```
Error: object 'x' not found
```




We can also estimate different evolutionary models for these traits to decide which best describes the data,



```r
bm <- fitContinuous(pruned$phy, pruned$data[["depths"]], 
    model = "BM")[[1]]
```



```
Error: subscript out of bounds
```



```r
ou <- fitContinuous(pruned$phy, pruned$data[["depths"]], 
    model = "OU")[[1]]
```



```
Error: subscript out of bounds
```




where the Brownian motion model has an AIC score of 

```

Error in unique(c("AsIs", oldClass(x))) : object 'bm' not found

```

 while
the OU model has a score of 

```

Error in unique(c("AsIs", oldClass(x))) : object 'ou' not found

```

, suggesting that


```

Error in which.min(list(BM = bm$aic, OU = ou$aic)) : 
  object 'bm' not found

```

 is the better model.


# Discussion



With more and more data readily available, informatics is becoming increasingly
important in ecology and evolution research [@jones2006], bringing new opportunities
for research [@parr2011a; @michener2012] while also raising new challenges [@reichman2011].
It is in this spirit that we introduce the `rfishbase` package to provide programmatic
access to the data available on the already widely recognized database, FishBase.  
We believe that such tools can help take greater advantage of the data available,
facilitating deeper and richer analyses than would be feasible under only manual access
to the data.  We hope the examples in this manuscript serve not only to illustrate how
this package works, but to help inspire readers to consider and explore questions
that would otherwise be too time consuming or challenging to pursue.  


In this paper we have introduced the functions of the `rfishbase` package
and described how they can be used to improve the extraction, visualization,
and integration of FishBase data in ecological and evolutionary research.  


## The self-updating study
Because analyses using this data are written in R scripts, it becomes easy to update
the results as more data becomes available on FishBase. Programmatic access to data
coupled with script-able analyses can help ensure that research is more easily reproduced
and also facilitate extending the work in future studies [@peng2011b; @merali2010].
This document is an example of this, using a dynamic documentation interpreter program 
which runs the code displayed to produce the results shown, eliminating the possibility
of faulty code [@knitr].  As FishBase is updated, we can regenerate these results 
with less missing data.  Readers can find the original document which combines the 
source-code and text on the project's [Github page](https://github.com/ropensci/rfishbase/tree/master/inst/doc/rfishbase)

## Limitations and future directions

FishBase contains much additional data that has not been made accessible
in its machine-readable XML format. We are in contact with the database
managers and look forward to providing access to additional types of
data as they become available.  Because most of the data provided in the 
XML comes as plain text rather that being identified with machine-readable
tags, reliability of the results is limited by text matching.  Meanwhile,
improved text matching queries could provide more reliable and other custom
information, such as extracting geographic distribution details as categorical
variables or latitude/longitude coordinates.  FishBase taxonomy is inconsistent
with taxonomy provided elsewhere, and additional package functions could help
resolve these differences in assignments.  

`rfishbase` has been available to R users through the [Comprehensive R Archive 
Network](http://cran.r-project.org/web/packages/rfishbase/) since October 2011, 
and has an established user base.  The project remains in active development
to evolve with the needs of its users.  Users can view the most recent changes 
and file issues with the package on its development website on Github,
([https://github.com/ropensci/rfishbase](https://github.com/ropensci/rfishbase))
and developers can submit changes to the code or adapt it into their own software. 

Programmers of other R software packages can make
use of the `rfishbase` package to make this data available to their
functions, further increasing the use and impact of FishBase. For
instance, the project [OpenFisheries](http://OpenFisheries.org) makes use 
of the `rfishbase` package to provide information about commercially relevant species.


# Acknowledgements

CB is supported by a Computational Sciences Graduate Fellowship from the
Department of Energy under grant number DE-FG02-97ER25308.

# References

