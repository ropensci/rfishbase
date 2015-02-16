---
title: "rfishbase 2.0"
author: "Carl Boettiger"
date: "2015-02-16"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{rfishbase 2.0}
  %\VignetteEngine{knitr::rmarkdown}
  \usepackage[utf8]{inputenc}
---

[![Build Status](https://travis-ci.org/ropensci/rfishbase.svg?branch=rfishbase2.0)](https://travis-ci.org/ropensci/rfishbase)  [![Coverage Status](https://coveralls.io/repos/ropensci/rfishbase/badge.svg?branch=rfishbase2.0)](https://coveralls.io/r/ropensci/rfishbase?branch=rfishbase2.0)

Welcome to `rfishbase 2.0`. 

This branch represents a work in progress and will not be functional until the FishBase API is released.
At this time endpoints are still being added to the API and implemented in the package.

## Quickstart 

Install: 

```r
  devtools::install_github("ropensci/rfishbase@rfishbase2.0")
```

Assemble a list of species:


```r
library(rfishbase)
my_species <- c(common_to_sci("trout"), 
                species_list(Genus = "Labriodes"), 
                species_list(Family = "Scaridae"))
```

```
## Error: could not find function "as"
```


Extract data tables for the listed species:


```r
species_info(my_species)
```

```
## Error in lapply(species_list, function(species) {: object 'my_species' not found
```


## Package Overview

Design principles:

Most functions are designed to take a character vector of species names as input and return a `data.frame`
as output; usually with species as rows and columns as variables measured on the species.


Species names must be valid scientific names as recognized by FishBase.

Getting good species names:

- `species_list()` Is probably the most common entry point for generating a list of species by specifying a higher taxonomic group of interest.  
- `common_to_sci()` Gives  a list of scientific names matching the queried common name(s).
- `synonyms()` Scientific names change frequently and thus taxonomy differs across databases.  Consequently, FishBase may not use the same scientific name you are familiar with.  This function will return a table of species names that FishBase recognizes as synonyms of the query, with a column, `Valid` indicating if it is the accepted species name used in the FishBase database or not.  For any of the other queries to work that rely on scientific names, be sure to use this accepted synonym.  


