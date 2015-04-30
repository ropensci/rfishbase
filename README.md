<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Build Status](https://travis-ci.org/ropensci/rfishbase.svg?branch=rfishbase2.0)](https://travis-ci.org/ropensci/rfishbase) [![Coverage Status](https://coveralls.io/repos/ropensci/rfishbase/badge.svg?branch=rfishbase2.0)](https://coveralls.io/r/ropensci/rfishbase?branch=rfishbase2.0) [![Downloads](http://cranlogs-dev.r-pkg.org/badges/rfishbase)](https://github.com/metacran/cranlogs.app)

Welcome to `rfishbase 2.0`.

This branch represents a work in progress and will not be functional until the FishBase API is released. At this time endpoints are still being added to the API and implemented in the package.

Installation
------------

``` r
install.packages("rfishbase", 
                 repos = c("http://carlboettiger.info/drat", "http://cran.rstudio.com"), 
                 type="source")
```

``` r
library("rfishbase")
```

Getting started
---------------

[FishBase](http://fishbase.org) makes it relatively easy to look up a lot of information on most known species of fish. However, looking up a single bit of data, such as the estimated trophic level, for many different species becomes tedious very soon. This is a common reason for using `rfishbase`. As such, our first step is to assemble a good list of species we are interested in.

### Building a species list

Almost all functions in `rfishbase` take a list (character vector) of species scientific names, for example:

``` r
fish <- c("Oreochromis niloticus", "Salmo trutta")
```

You can also read in a list of names from any existing data you are working with. When providing your own species list, you should always begin by validating the names. Taxonomy is a moving target, and this well help align the scientific names you are using with the names used by FishBase, and alert you to any potential issues:

``` r
fish <- validate_names(c("Oreochromis niloticus", "Salmo trutta"))
```

Another typical use case is in wanting to collect information about all species in a particular taxonomic group, such as a Genus, Family or Order. The function `species_list` recognizes six taxonomic levels, and can help you generate a list of names of all species in a given group:

``` r
fish <- species_list(Genus = "Labriodes")
fish
```

    # output: character(0)

`rfishbase` also recognizes common names. When a common name refers to multiple species, all matching species are returned:

``` r
fish <- common_to_sci("trout")
fish
```

    # output: [1] "Salmo trutta"               "Oncorhynchus mykiss"       
    # output: [3] "Salvelinus fontinalis"      "Salvelinus alpinus alpinus"
    # output: [5] "Lethrinus miniatus"         "Salvelinus malma"          
    # output: [7] "Plectropomus leopardus"     "Schizothorax richardsonii" 
    # output: [9] "Arripis truttacea"

Note that there is no need to validate names coming from `common_to_sci` or `species_list`, as these will always return valid names.

### Getting data

With a species list in place, we are ready to query fishbase for data. Note that if you have a very long list of species, it is always a good idea to try out your intended functions with a subset of that list first to make sure everything is working.

The `species()` function returns a table containing much (but not all) of the information found on the summary or homepage for a species on [fishbase.org](http://fishbase.org). `rfishbase` functions always return [tidy](http://www.jstatsoft.org/v59/i10/paper) data tables: rows are observations (e.g. a species, individual samples from a species) and columns are variables (fields).

``` r
species(fish[1:2])
```

    # output: Source: local data frame [2 x 97]
    # output: 
    # output:   SpecCode        Genus Species SpeciesRefNo          Author        FBname
    # output: 1      238        Salmo  trutta         4779  Linnaeus, 1758     Sea trout
    # output: 2      239 Oncorhynchus  mykiss         4706 (Walbaum, 1792) Rainbow trout
    # output: Variables not shown: PicPreferredName (chr), PicPreferredNameM (chr),
    # output:   PicPreferredNameF (chr), PicPreferredNameJ (chr), FamCode (int),
    # output:   Subfamily (chr), GenCode (int), SubGenCode (int), BodyShapeI (chr),
    # output:   Source (chr), Remark (chr), TaxIssue (chr), Fresh (lgl), Brack (lgl),
    # output:   Saltwater (lgl), DemersPelag (chr), AnaCat (chr), MigratRef (chr),
    # output:   DepthRangeShallow (dbl), DepthRangeDeep (dbl), DepthRangeRef (int),
    # output:   DepthRangeComShallow (dbl), DepthRangeComDeep (dbl), DepthComRef (int),
    # output:   LongevityWild (dbl), LongevityWildRef (int), LongevityCaptive (dbl),
    # output:   LongevityCapRef (int), Vulnerability (dbl), Length (dbl), LTypeMaxM
    # output:   (chr), LengthFemale (dbl), LTypeMaxF (chr), MaxLengthRef (int),
    # output:   CommonLength (chr), LTypeComM (chr), CommonLengthF (chr), LTypeComF
    # output:   (chr), CommonLengthRef (int), Weight (dbl), WeightFemale (chr),
    # output:   MaxWeightRef (int), Pic (chr), PictureFemale (chr), LarvaPic (chr),
    # output:   EggPic (chr), ImportanceRef (chr), Importance (chr), PriceCateg (chr),
    # output:   PriceReliability (chr), Remarks7 (chr), LandingStatistics (chr),
    # output:   Landings (chr), MainCatchingMethod (chr), II (chr), MSeines (lgl),
    # output:   MGillnets (lgl), MCastnets (lgl), MTraps (lgl), MSpears (lgl), MTrawls
    # output:   (lgl), MDredges (lgl), MLiftnets (lgl), MHooksLines (lgl), MOther (lgl),
    # output:   UsedforAquaculture (chr), LifeCycle (chr), AquacultureRef (chr),
    # output:   UsedasBait (chr), BaitRef (chr), Aquarium (chr), AquariumFishII (chr),
    # output:   AquariumRef (chr), GameFish (lgl), GameRef (int), Dangerous (chr),
    # output:   DangerousRef (int), Electrogenic (chr), ElectroRef (int), Complete
    # output:   (chr), GoogleImage (lgl), Comments (chr), Profile (chr), PD50 (chr),
    # output:   Entered (int), DateEntered (date), Modified (int), DateModified (date),
    # output:   Expert (int), DateChecked (date), TS (chr)

Most tables contain many fields. To avoid overly cluttering the screen, `rfishbase` displays tables as `data_frame` objects from the `dplyr` package. These act just like the familiar `data.frames` of base R except that they print to the screen in a more tidy fashion. Note that columns that cannot fit easily in the display are summarized below the table. This gives us an easy way to see what fields are available in a given table. For instance, from this table we may only be interested in the `PriceCateg` (Price category) and the `Vulnerability` of the species. We can repeat the query for our full species list, asking for only these fields to be returned:

``` r
species(fish, fields=c("SpecCode", "PriceCateg", "Vulnerability"))
```

    # output: Source: local data frame [9 x 3]
    # output: 
    # output:   SpecCode PriceCateg Vulnerability
    # output: 1      238  very high         59.96
    # output: 2      239        low         35.97
    # output: 3      246  very high         43.37
    # output: 4      247  very high         74.33
    # output: 5     1858  very high         52.78
    # output: 6     2691  very high         69.97
    # output: 7     4826  very high         51.04
    # output: 8     8705    unknown         34.78
    # output: 9    14606    unknown         47.96

Note that we also request `SpecCode`, the species code which uniquely identifies the species. Almost all tables include a field for `SpecCode`, which can be useful for joining these results with other tables later. The `SpecCode`s can always be converted into species names using the `speciesnames()` function. Here we add a column with the corresponding species name:

``` r
data <- species(fish, fields=c("SpecCode", "PriceCateg", "Vulnerability"))
data <- cbind(species = speciesnames(data$SpecCode), data)
```

Unfortunately identifying what fields come from which tables is often a challenge. Each summary page on fishbase.org includes a list of additional tables with more information about species ecology, diet, occurrences, and many other things. `rfishbase` provides functions that correspond to most of these tables. Because `rfishbase` accesses the back end database, it does not always line up with the web display. Frequently `rfishbase` functions will return more information than is available on the web versions of the these tables. Some information found in on the summary homepage for a species is not available from the `summary` function, but must be extracted from a different table, such as the species `Resilience`, which appears on the `stocks` table. Working in R, it is easy to query this additional table and combine the results with the data we have collected so far:

``` r
resil <- stocks(fish, fields="Resilience")
merge(data, resil)
```

    # output:                        species SpecCode PriceCateg Vulnerability
    # output: 1                 Salmo trutta      238  very high         59.96
    # output: 2          Oncorhynchus mykiss      239        low         35.97
    # output: 3        Salvelinus fontinalis      246  very high         43.37
    # output: 4   Salvelinus alpinus alpinus      247  very high         74.33
    # output: 5           Lethrinus miniatus     1858  very high         52.78
    # output: 6             Salvelinus malma     2691  very high         69.97
    # output: 7       Plectropomus leopardus     4826  very high         51.04
    # output: 8    Schizothorax richardsonii     8705    unknown         34.78
    # output: 9            Arripis truttacea    14606    unknown         47.96
    # output: 10                Salmo trutta      238  very high         59.96
    # output: 11         Oncorhynchus mykiss      239        low         35.97
    # output: 12       Salvelinus fontinalis      246  very high         43.37
    # output: 13  Salvelinus alpinus alpinus      247  very high         74.33
    # output: 14          Lethrinus miniatus     1858  very high         52.78
    # output: 15            Salvelinus malma     2691  very high         69.97
    # output: 16      Plectropomus leopardus     4826  very high         51.04
    # output: 17   Schizothorax richardsonii     8705    unknown         34.78
    # output: 18           Arripis truttacea    14606    unknown         47.96
    # output: 19                Salmo trutta      238  very high         59.96
    # output: 20         Oncorhynchus mykiss      239        low         35.97
    # output: 21       Salvelinus fontinalis      246  very high         43.37
    # output: 22  Salvelinus alpinus alpinus      247  very high         74.33
    # output: 23          Lethrinus miniatus     1858  very high         52.78
    # output: 24            Salvelinus malma     2691  very high         69.97
    # output: 25      Plectropomus leopardus     4826  very high         51.04
    # output: 26   Schizothorax richardsonii     8705    unknown         34.78
    # output: 27           Arripis truttacea    14606    unknown         47.96
    # output: 28                Salmo trutta      238  very high         59.96
    # output: 29         Oncorhynchus mykiss      239        low         35.97
    # output: 30       Salvelinus fontinalis      246  very high         43.37
    # output: 31  Salvelinus alpinus alpinus      247  very high         74.33
    # output: 32          Lethrinus miniatus     1858  very high         52.78
    # output: 33            Salvelinus malma     2691  very high         69.97
    # output: 34      Plectropomus leopardus     4826  very high         51.04
    # output: 35   Schizothorax richardsonii     8705    unknown         34.78
    # output: 36           Arripis truttacea    14606    unknown         47.96
    # output: 37                Salmo trutta      238  very high         59.96
    # output: 38         Oncorhynchus mykiss      239        low         35.97
    # output: 39       Salvelinus fontinalis      246  very high         43.37
    # output: 40  Salvelinus alpinus alpinus      247  very high         74.33
    # output: 41          Lethrinus miniatus     1858  very high         52.78
    # output: 42            Salvelinus malma     2691  very high         69.97
    # output: 43      Plectropomus leopardus     4826  very high         51.04
    # output: 44   Schizothorax richardsonii     8705    unknown         34.78
    # output: 45           Arripis truttacea    14606    unknown         47.96
    # output: 46                Salmo trutta      238  very high         59.96
    # output: 47         Oncorhynchus mykiss      239        low         35.97
    # output: 48       Salvelinus fontinalis      246  very high         43.37
    # output: 49  Salvelinus alpinus alpinus      247  very high         74.33
    # output: 50          Lethrinus miniatus     1858  very high         52.78
    # output: 51            Salvelinus malma     2691  very high         69.97
    # output: 52      Plectropomus leopardus     4826  very high         51.04
    # output: 53   Schizothorax richardsonii     8705    unknown         34.78
    # output: 54           Arripis truttacea    14606    unknown         47.96
    # output: 55                Salmo trutta      238  very high         59.96
    # output: 56         Oncorhynchus mykiss      239        low         35.97
    # output: 57       Salvelinus fontinalis      246  very high         43.37
    # output: 58  Salvelinus alpinus alpinus      247  very high         74.33
    # output: 59          Lethrinus miniatus     1858  very high         52.78
    # output: 60            Salvelinus malma     2691  very high         69.97
    # output: 61      Plectropomus leopardus     4826  very high         51.04
    # output: 62   Schizothorax richardsonii     8705    unknown         34.78
    # output: 63           Arripis truttacea    14606    unknown         47.96
    # output: 64                Salmo trutta      238  very high         59.96
    # output: 65         Oncorhynchus mykiss      239        low         35.97
    # output: 66       Salvelinus fontinalis      246  very high         43.37
    # output: 67  Salvelinus alpinus alpinus      247  very high         74.33
    # output: 68          Lethrinus miniatus     1858  very high         52.78
    # output: 69            Salvelinus malma     2691  very high         69.97
    # output: 70      Plectropomus leopardus     4826  very high         51.04
    # output: 71   Schizothorax richardsonii     8705    unknown         34.78
    # output: 72           Arripis truttacea    14606    unknown         47.96
    # output: 73                Salmo trutta      238  very high         59.96
    # output: 74         Oncorhynchus mykiss      239        low         35.97
    # output: 75       Salvelinus fontinalis      246  very high         43.37
    # output: 76  Salvelinus alpinus alpinus      247  very high         74.33
    # output: 77          Lethrinus miniatus     1858  very high         52.78
    # output: 78            Salvelinus malma     2691  very high         69.97
    # output: 79      Plectropomus leopardus     4826  very high         51.04
    # output: 80   Schizothorax richardsonii     8705    unknown         34.78
    # output: 81           Arripis truttacea    14606    unknown         47.96
    # output: 82                Salmo trutta      238  very high         59.96
    # output: 83         Oncorhynchus mykiss      239        low         35.97
    # output: 84       Salvelinus fontinalis      246  very high         43.37
    # output: 85  Salvelinus alpinus alpinus      247  very high         74.33
    # output: 86          Lethrinus miniatus     1858  very high         52.78
    # output: 87            Salvelinus malma     2691  very high         69.97
    # output: 88      Plectropomus leopardus     4826  very high         51.04
    # output: 89   Schizothorax richardsonii     8705    unknown         34.78
    # output: 90           Arripis truttacea    14606    unknown         47.96
    # output: 91                Salmo trutta      238  very high         59.96
    # output: 92         Oncorhynchus mykiss      239        low         35.97
    # output: 93       Salvelinus fontinalis      246  very high         43.37
    # output: 94  Salvelinus alpinus alpinus      247  very high         74.33
    # output: 95          Lethrinus miniatus     1858  very high         52.78
    # output: 96            Salvelinus malma     2691  very high         69.97
    # output: 97      Plectropomus leopardus     4826  very high         51.04
    # output: 98   Schizothorax richardsonii     8705    unknown         34.78
    # output: 99           Arripis truttacea    14606    unknown         47.96
    # output: 100               Salmo trutta      238  very high         59.96
    # output: 101        Oncorhynchus mykiss      239        low         35.97
    # output: 102      Salvelinus fontinalis      246  very high         43.37
    # output: 103 Salvelinus alpinus alpinus      247  very high         74.33
    # output: 104         Lethrinus miniatus     1858  very high         52.78
    # output: 105           Salvelinus malma     2691  very high         69.97
    # output: 106     Plectropomus leopardus     4826  very high         51.04
    # output: 107  Schizothorax richardsonii     8705    unknown         34.78
    # output: 108          Arripis truttacea    14606    unknown         47.96
    # output: 109               Salmo trutta      238  very high         59.96
    # output: 110        Oncorhynchus mykiss      239        low         35.97
    # output: 111      Salvelinus fontinalis      246  very high         43.37
    # output: 112 Salvelinus alpinus alpinus      247  very high         74.33
    # output: 113         Lethrinus miniatus     1858  very high         52.78
    # output: 114           Salvelinus malma     2691  very high         69.97
    # output: 115     Plectropomus leopardus     4826  very high         51.04
    # output: 116  Schizothorax richardsonii     8705    unknown         34.78
    # output: 117          Arripis truttacea    14606    unknown         47.96
    # output: 118               Salmo trutta      238  very high         59.96
    # output: 119        Oncorhynchus mykiss      239        low         35.97
    # output: 120      Salvelinus fontinalis      246  very high         43.37
    # output: 121 Salvelinus alpinus alpinus      247  very high         74.33
    # output: 122         Lethrinus miniatus     1858  very high         52.78
    # output: 123           Salvelinus malma     2691  very high         69.97
    # output: 124     Plectropomus leopardus     4826  very high         51.04
    # output: 125  Schizothorax richardsonii     8705    unknown         34.78
    # output: 126          Arripis truttacea    14606    unknown         47.96
    # output: 127               Salmo trutta      238  very high         59.96
    # output: 128        Oncorhynchus mykiss      239        low         35.97
    # output: 129      Salvelinus fontinalis      246  very high         43.37
    # output: 130 Salvelinus alpinus alpinus      247  very high         74.33
    # output: 131         Lethrinus miniatus     1858  very high         52.78
    # output: 132           Salvelinus malma     2691  very high         69.97
    # output: 133     Plectropomus leopardus     4826  very high         51.04
    # output: 134  Schizothorax richardsonii     8705    unknown         34.78
    # output: 135          Arripis truttacea    14606    unknown         47.96
    # output: 136               Salmo trutta      238  very high         59.96
    # output: 137        Oncorhynchus mykiss      239        low         35.97
    # output: 138      Salvelinus fontinalis      246  very high         43.37
    # output: 139 Salvelinus alpinus alpinus      247  very high         74.33
    # output: 140         Lethrinus miniatus     1858  very high         52.78
    # output: 141           Salvelinus malma     2691  very high         69.97
    # output: 142     Plectropomus leopardus     4826  very high         51.04
    # output: 143  Schizothorax richardsonii     8705    unknown         34.78
    # output: 144          Arripis truttacea    14606    unknown         47.96
    # output:     Resilience
    # output: 1       Medium
    # output: 2       Medium
    # output: 3       Medium
    # output: 4       Medium
    # output: 5       Medium
    # output: 6       Medium
    # output: 7       Medium
    # output: 8       Medium
    # output: 9       Medium
    # output: 10      Medium
    # output: 11      Medium
    # output: 12      Medium
    # output: 13      Medium
    # output: 14      Medium
    # output: 15      Medium
    # output: 16      Medium
    # output: 17      Medium
    # output: 18      Medium
    # output: 19      Medium
    # output: 20      Medium
    # output: 21      Medium
    # output: 22      Medium
    # output: 23      Medium
    # output: 24      Medium
    # output: 25      Medium
    # output: 26      Medium
    # output: 27      Medium
    # output: 28         Low
    # output: 29         Low
    # output: 30         Low
    # output: 31         Low
    # output: 32         Low
    # output: 33         Low
    # output: 34         Low
    # output: 35         Low
    # output: 36         Low
    # output: 37      Medium
    # output: 38      Medium
    # output: 39      Medium
    # output: 40      Medium
    # output: 41      Medium
    # output: 42      Medium
    # output: 43      Medium
    # output: 44      Medium
    # output: 45      Medium
    # output: 46        <NA>
    # output: 47        <NA>
    # output: 48        <NA>
    # output: 49        <NA>
    # output: 50        <NA>
    # output: 51        <NA>
    # output: 52        <NA>
    # output: 53        <NA>
    # output: 54        <NA>
    # output: 55        <NA>
    # output: 56        <NA>
    # output: 57        <NA>
    # output: 58        <NA>
    # output: 59        <NA>
    # output: 60        <NA>
    # output: 61        <NA>
    # output: 62        <NA>
    # output: 63        <NA>
    # output: 64      Medium
    # output: 65      Medium
    # output: 66      Medium
    # output: 67      Medium
    # output: 68      Medium
    # output: 69      Medium
    # output: 70      Medium
    # output: 71      Medium
    # output: 72      Medium
    # output: 73      Medium
    # output: 74      Medium
    # output: 75      Medium
    # output: 76      Medium
    # output: 77      Medium
    # output: 78      Medium
    # output: 79      Medium
    # output: 80      Medium
    # output: 81      Medium
    # output: 82         Low
    # output: 83         Low
    # output: 84         Low
    # output: 85         Low
    # output: 86         Low
    # output: 87         Low
    # output: 88         Low
    # output: 89         Low
    # output: 90         Low
    # output: 91      Medium
    # output: 92      Medium
    # output: 93      Medium
    # output: 94      Medium
    # output: 95      Medium
    # output: 96      Medium
    # output: 97      Medium
    # output: 98      Medium
    # output: 99      Medium
    # output: 100        Low
    # output: 101        Low
    # output: 102        Low
    # output: 103        Low
    # output: 104        Low
    # output: 105        Low
    # output: 106        Low
    # output: 107        Low
    # output: 108        Low
    # output: 109   Very low
    # output: 110   Very low
    # output: 111   Very low
    # output: 112   Very low
    # output: 113   Very low
    # output: 114   Very low
    # output: 115   Very low
    # output: 116   Very low
    # output: 117   Very low
    # output: 118     Medium
    # output: 119     Medium
    # output: 120     Medium
    # output: 121     Medium
    # output: 122     Medium
    # output: 123     Medium
    # output: 124     Medium
    # output: 125     Medium
    # output: 126     Medium
    # output: 127     Medium
    # output: 128     Medium
    # output: 129     Medium
    # output: 130     Medium
    # output: 131     Medium
    # output: 132     Medium
    # output: 133     Medium
    # output: 134     Medium
    # output: 135     Medium
    # output: 136     Medium
    # output: 137     Medium
    # output: 138     Medium
    # output: 139     Medium
    # output: 140     Medium
    # output: 141     Medium
    # output: 142     Medium
    # output: 143     Medium
    # output: 144     Medium
