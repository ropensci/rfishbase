<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Build Status](https://travis-ci.org/ropensci/rfishbase.svg?branch=rfishbase2.0)](https://travis-ci.org/ropensci/rfishbase) [![Coverage Status](https://coveralls.io/repos/ropensci/rfishbase/badge.svg?branch=rfishbase2.0)](https://coveralls.io/r/ropensci/rfishbase?branch=rfishbase2.0) [![Downloads](http://cranlogs.r-pkg.org/badges/rfishbase)](https://github.com/metacran/cranlogs.app)

Welcome to `rfishbase 2.0`.

This branch represents a work in progress and will not be functional until the FishBase API is released. At this time endpoints are still being added to the API and implemented in the package.

Installation
------------

``` r
install.packages("rfishbase", 
                 repos = c("http://carlboettiger.info/drat", "http://cran.rstudio.com"), 
                 type="source")
```

    Installing package into '/usr/local/lib/R/site-library'
    (as 'lib' is unspecified)


    The downloaded source packages are in
        '/tmp/Rtmpn091ky/downloaded_packages'

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
fish <- species_list(Genus = "Labroides")
fish
```

    [1] "Labroides bicolor"       "Labroides dimidiatus"   
    [3] "Labroides pectoralis"    "Labroides phthirophagus"
    [5] "Labroides rubrolabiatus"

`rfishbase` also recognizes common names. When a common name refers to multiple species, all matching species are returned:

``` r
fish <- common_to_sci("trout")
fish
```

    [1] "Salmo trutta"               "Oncorhynchus mykiss"       
    [3] "Salvelinus fontinalis"      "Salvelinus alpinus alpinus"
    [5] "Lethrinus miniatus"         "Salvelinus malma"          
    [7] "Plectropomus leopardus"     "Schizothorax richardsonii" 
    [9] "Arripis truttacea"         

Note that there is no need to validate names coming from `common_to_sci` or `species_list`, as these will always return valid names.

### Getting data

With a species list in place, we are ready to query fishbase for data. Note that if you have a very long list of species, it is always a good idea to try out your intended functions with a subset of that list first to make sure everything is working.

The `species()` function returns a table containing much (but not all) of the information found on the summary or homepage for a species on [fishbase.org](http://fishbase.org). `rfishbase` functions always return [tidy](http://www.jstatsoft.org/v59/i10/paper) data tables: rows are observations (e.g. a species, individual samples from a species) and columns are variables (fields).

``` r
species(fish[1:2])
```

    Source: local data frame [2 x 99]

                  sciname        Genus Species SpeciesRefNo          Author
    1        Salmo trutta        Salmo  trutta         4779  Linnaeus, 1758
    2 Oncorhynchus mykiss Oncorhynchus  mykiss         4706 (Walbaum, 1792)
    Variables not shown: FBname (chr), PicPreferredName (chr),
      PicPreferredNameM (lgl), PicPreferredNameF (lgl), PicPreferredNameJ
      (chr), FamCode (int), Subfamily (chr), GenCode (int), SubGenCode (lgl),
      BodyShapeI (chr), Source (chr), AuthorRef (lgl), Remark (lgl), TaxIssue
      (int), Fresh (int), Brack (int), Saltwater (int), DemersPelag (chr),
      AnaCat (chr), MigratRef (int), DepthRangeShallow (int), DepthRangeDeep
      (int), DepthRangeRef (int), DepthRangeComShallow (lgl),
      DepthRangeComDeep (int), DepthComRef (lgl), LongevityWild (dbl),
      LongevityWildRef (int), LongevityCaptive (dbl), LongevityCapRef (int),
      Vulnerability (dbl), Length (dbl), LTypeMaxM (chr), LengthFemale (lgl),
      LTypeMaxF (lgl), MaxLengthRef (int), CommonLength (dbl), LTypeComM
      (chr), CommonLengthF (lgl), LTypeComF (lgl), CommonLengthRef (int),
      Weight (dbl), WeightFemale (lgl), MaxWeightRef (int), Pic (chr),
      PictureFemale (lgl), LarvaPic (lgl), EggPic (lgl), ImportanceRef (int),
      Importance (chr), PriceCateg (chr), PriceReliability (chr), Remarks7
      (chr), LandingStatistics (chr), Landings (chr), MainCatchingMethod
      (chr), II (chr), MSeines (int), MGillnets (int), MCastnets (int), MTraps
      (int), MSpears (int), MTrawls (int), MDredges (int), MLiftnets (int),
      MHooksLines (int), MOther (int), UsedforAquaculture (chr), LifeCycle
      (chr), AquacultureRef (int), UsedasBait (chr), BaitRef (lgl), Aquarium
      (chr), AquariumFishII (chr), AquariumRef (int), GameFish (int), GameRef
      (int), Dangerous (chr), DangerousRef (lgl), Electrogenic (chr),
      ElectroRef (lgl), Complete (lgl), GoogleImage (int), Comments (chr),
      Profile (lgl), PD50 (dbl), Emblematic (int), Entered (int), DateEntered
      (chr), Modified (int), DateModified (chr), Expert (int), DateChecked
      (chr), TS (lgl)

Most tables contain many fields. To avoid overly cluttering the screen, `rfishbase` displays tables as `data_frame` objects from the `dplyr` package. These act just like the familiar `data.frames` of base R except that they print to the screen in a more tidy fashion. Note that columns that cannot fit easily in the display are summarized below the table. This gives us an easy way to see what fields are available in a given table. For instance, from this table we may only be interested in the `PriceCateg` (Price category) and the `Vulnerability` of the species. We can repeat the query for our full species list, asking for only these fields to be returned:

``` r
dat <- species(fish, fields=c("SpecCode", "PriceCateg", "Vulnerability"))
dat
```

    Source: local data frame [9 x 3]

                         sciname PriceCateg Vulnerability
    1               Salmo trutta  very high         59.96
    2        Oncorhynchus mykiss        low         36.29
    3      Salvelinus fontinalis  very high         43.37
    4 Salvelinus alpinus alpinus  very high         74.33
    5         Lethrinus miniatus  very high         52.78
    6           Salvelinus malma  very high         69.97
    7     Plectropomus leopardus  very high         51.04
    8  Schizothorax richardsonii    unknown         34.78
    9          Arripis truttacea    unknown         47.96

Unfortunately identifying what fields come from which tables is often a challenge. Each summary page on fishbase.org includes a list of additional tables with more information about species ecology, diet, occurrences, and many other things. `rfishbase` provides functions that correspond to most of these tables. Because `rfishbase` accesses the back end database, it does not always line up with the web display. Frequently `rfishbase` functions will return more information than is available on the web versions of the these tables. Some information found on the summary homepage for a species is not available from the `summary` function, but must be extracted from a different table, such as the species `Resilience`, which appears on the `stocks` table. Working in R, it is easy to query this additional table and combine the results with the data we have collected so far:

``` r
resil <- stocks(fish, fields="Resilience")
merge(dat, resil)
```

                          sciname PriceCateg Vulnerability Resilience
    1           Arripis truttacea    unknown         47.96     Medium
    2          Lethrinus miniatus  very high         52.78     Medium
    3         Oncorhynchus mykiss        low         36.29     Medium
    4      Plectropomus leopardus  very high         51.04     Medium
    5                Salmo trutta  very high         59.96       High
    6                Salmo trutta  very high         59.96       <NA>
    7                Salmo trutta  very high         59.96     Medium
    8                Salmo trutta  very high         59.96        Low
    9                Salmo trutta  very high         59.96       <NA>
    10               Salmo trutta  very high         59.96       <NA>
    11               Salmo trutta  very high         59.96       <NA>
    12 Salvelinus alpinus alpinus  very high         74.33        Low
    13      Salvelinus fontinalis  very high         43.37     Medium
    14           Salvelinus malma  very high         69.97        Low
    15           Salvelinus malma  very high         69.97       <NA>
    16  Schizothorax richardsonii    unknown         34.78     Medium

------------------------------------------------------------------------

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

[![ropensci\_footer](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
