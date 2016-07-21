<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Build Status](https://travis-ci.org/ropensci/rfishbase.svg?branch=rfishbase2.0)](https://travis-ci.org/ropensci/rfishbase) [![Coverage Status](https://coveralls.io/repos/ropensci/rfishbase/badge.svg?branch=rfishbase2.0)](https://coveralls.io/r/ropensci/rfishbase?branch=rfishbase2.0) [![Downloads](http://cranlogs.r-pkg.org/badges/rfishbase)](https://github.com/metacran/cranlogs.app)

Welcome to `rfishbase 2.0`. This package is a ground-up rewrite of the original `rfishbase` package described in [Boettiger et al. (2012)](http://www.carlboettiger.info/assets/files/pubs/10.1111/j.1095-8649.2012.03464.x.pdf), and is not backwards compatible with the original. The first version of `rfishbase` relied on the XML summary pages provided by FishBase, which contained relatively incomplete data and have since been deprecated. The package later added functions that relied on HTML scraping of fishbase.org, which was always slow, subject to server instabilities, and carried a greater risk of errors. To address all of these issues, we have now created a stand-alone FishBase API with the blessing of the FishBase.org team, who have kindly provided copies of the backend SQL database to our team for this purpose. At this time the API does not cover all tables provided by the SQL backend, but does access the largest and most commonly used. A list of all tables available from the API (and from rfishbase) can be seen using the `heartbeat()` function.

The new `rfishbase` package queries this API directly rather than the FishBase.org website. This reduces load on the FishBase web servers and increases both the performance and the breadth of data avaialble. `rfishbase` functions are primarily aimed at facilitating queries for specific data across a given list of many species. This is a task that is common to much scientific research and tedious to perform on the FishBase.org website, which requires a user to visit a separate page for each species. Aimed at scientific use, the `rfishbase` package returns all data as `data.frames`, usually organized in "tidy data" style with individual species as rows and observations of species traits as columns (also referred to as fields). Users will frequently have to subset the resulting data frames, or join them with other data frames provided by the package, to obtain the data they need. We recommend the `dplyr` package to facilitate these tasks, which `rfishbase` also uses internally.

In having access to much more data, the new `rfishbase` can be difficult to navigate. We have provided several helper functions for users to discover which tables they need, as illustrated below. Unfortunately, FishBase.org lacks detailed documentation of all of the tables and fields contained in it's database. For the most part, table and column names are self-documenting, but details are often missing which can create a puzzle for researchers trying to figure out precisely what data is provided in a given column. To address this challenge, we have created a crowd-sourced collection of documentation that can be queried from the API to provide more detailed descriptions.

We welcome any feedback, issues or questions that users may encounter through our issues tracker on GitHub: \[<https://github.com/ropensci/rfishbase/issues>\].

Installation
------------

``` r
install.packages("rfishbase", 
                 repos = c("http://packages.ropensci.org", "http://cran.rstudio.com"), 
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

                  sciname        Genus Species SpeciesRefNo          Author
    1        Salmo trutta        Salmo  trutta         4779  Linnaeus, 1758
    2 Oncorhynchus mykiss Oncorhynchus  mykiss         4706 (Walbaum, 1792)
             FBname PicPreferredName PicPreferredNameM PicPreferredNameF
    1     Sea trout     Satru_u2.jpg                NA                NA
    2 Rainbow trout     Onmyk_f0.jpg                NA                NA
      PicPreferredNameJ FamCode  Subfamily GenCode SubGenCode
    1      Satru_uc.jpg      76 Salmoninae    6009         NA
    2              <NA>      76 Salmoninae    2445         NA
             BodyShapeI Source AuthorRef Remark TaxIssue Fresh Brack Saltwater
    1 fusiform / normal      R        NA     NA        0    -1    -1        -1
    2 fusiform / normal      R        NA     NA        0    -1    -1        -1
          DemersPelag     AnaCat MigratRef DepthRangeShallow DepthRangeDeep
    1 pelagic-neritic anadromous     51243                 0             NA
    2   benthopelagic anadromous     51243                 0            200
      DepthRangeRef DepthRangeComShallow DepthRangeComDeep DepthComRef
    1            NA                   NA                10          NA
    2         50550                   NA                NA          NA
      LongevityWild LongevityWildRef LongevityCaptive LongevityCapRef
    1            38            32682             10.3             274
    2            11            12193              4.0             273
      Vulnerability Length LTypeMaxM LengthFemale LTypeMaxF MaxLengthRef
    1         59.96    140        SL           NA        NA          682
    2         36.29    122        TL           NA        NA        96339
      CommonLength LTypeComM CommonLengthF LTypeComF CommonLengthRef Weight
    1           72        TL            NA        NA            3397  50000
    2           60        TL            NA        NA            5504  25400
      WeightFemale MaxWeightRef      Pic PictureFemale LarvaPic EggPic
    1           NA          682 SATRU_U2            NA       NA     NA
    2           NA         7251 ONMYK_U2            NA       NA     NA
      ImportanceRef        Importance PriceCateg
    1          4931        commercial  very high
    2          4931 highly commercial        low
                                         PriceReliability             Remarks7
    1 Reliable: based on ex-vessel price for this species                 <NA>
    2 Reliable: based on ex-vessel price for this species Important game fish.
            LandingStatistics           Landings MainCatchingMethod II MSeines
    1    from 1,000 to 10,000 Finland in area 27             seines          0
    2 from 100,000 to 500,000               <NA>    hooks and lines          0
      MGillnets MCastnets MTraps MSpears MTrawls MDredges MLiftnets
    1        -1         0     -1       0       0        0         0
    2        -1         0      0       0       0        0         0
      MHooksLines MOther UsedforAquaculture
    1          -1      0         commercial
    2          -1      0         commercial
                                    LifeCycle AquacultureRef   UsedasBait
    1                                                  12228 never/rarely
    2 life cycle closed in commercial culture          12108 never/rarely
      BaitRef     Aquarium           AquariumFishII AquariumRef GameFish
    1      NA never/rarely based mainly on breeding         274       -1
    2      NA never/rarely  based mainly on capture        9183       -1
      GameRef      Dangerous DangerousRef       Electrogenic ElectroRef
    1    4699 potential pest           NA no special ability         NA
    2    4699 potential pest           NA no special ability         NA
      Complete GoogleImage
    1       NA          -1
    2       NA          -1
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     Comments
    1 Found in streams, ponds, rivers and lakes (Ref. 5951).  Individuals spend 1 to 5 years in fresh water and 6 months to 5 years in salt water (Ref. 51442).  Juveniles mature in 3-4 years (Ref. 6885).  Lacustrine populations undertake migration to tributaries and lake outlets to spawn, rarely spawning on stone, wave-washed lake shores.  Spawns in rivers and streams with swift current, usually characterized by downward movement of water intro gravel (Ref. 59043).  Spawning takes place normally more than one time (Ref. 51442).  They prefer cold, well-oxygenated upland waters although their tolerance limits are lower than those of rainbow trout and favors large streams in the mountainous areas with adequate cover in the form of submerged rocks, undercut banks, and overhanging vegetation (Ref. 6465).  Life history and spawning behavior is similar to the salmon <i>Salmo salar</i> (Ref. 51442).  Each female produces about 10.000 eggs (Ref. 35388, Ref. 51442).  Mainly diurnal (Ref. 682).  Sea and lake trouts forage in pelagic and littoral habitats, while sea trouts mainly close to coast, not very far from estuary of natal river (Ref. 59043).  Juveniles feed mainly on aquatic and terrestrial insects; adults on mollusks, crustaceans and small fish (Ref. 26523, Ref. 51442).  Marketed fresh and smoked; eaten fried, broiled, boiled, cooked in microwave, and baked (Ref. 9988).
    2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                Adults inhabit cold headwaters, creeks, small to large rivers, and lakes.  Anadromous in coastal streams (Ref. 5723).  Stocked in almost all water bodies as lakes, rivers and streams, usually not stocked in water reaching summer temperatures above 25°C or ponds with very low oxygen concentrations.  Feed on a variety of aquatic and terrestrial invertebrates and small fishes. At the sea, they prey on fish and cephalopods.  Mature individuals undertake short spawning migrations.  Anadromous and lake forms may migrate long distances to spawning streams (Ref. 59043). Utilized fresh, smoked, canned, and frozen; eaten steamed, fried, broiled, boiled, microwaved and baked (Ref. 9988).  Cultured in many countries and is often hatched and stocked into rivers and lakes especially to attract recreational fishers (Ref. 9988).
      Profile PD50 Emblematic Entered              DateEntered Modified
    1      NA  0.5          0       2 1990-10-17T00:00:00.000Z       10
    2      NA  0.5          0       2 1990-10-17T00:00:00.000Z     2291
                  DateModified Expert              DateChecked TS SpecCode
    1 2013-09-13T00:00:00.000Z     97 2003-01-03T00:00:00.000Z NA      238
    2 2014-12-16T00:00:00.000Z     97 2003-01-15T00:00:00.000Z NA      239

Most tables contain many fields. To avoid overly cluttering the screen, `rfishbase` displays tables as `data_frame` objects from the `dplyr` package. These act just like the familiar `data.frames` of base R except that they print to the screen in a more tidy fashion. Note that columns that cannot fit easily in the display are summarized below the table. This gives us an easy way to see what fields are available in a given table. For instance, from this table we may only be interested in the `PriceCateg` (Price category) and the `Vulnerability` of the species. We can repeat the query for our full species list, asking for only these fields to be returned:

``` r
dat <- species(fish, fields=c("SpecCode", "PriceCateg", "Vulnerability"))
dat
```

                         sciname Vulnerability PriceCateg SpecCode
    1               Salmo trutta         59.96  very high      238
    2        Oncorhynchus mykiss         36.29        low      239
    3      Salvelinus fontinalis         43.37  very high      246
    4 Salvelinus alpinus alpinus         74.33  very high      247
    5         Lethrinus miniatus         52.78  very high     1858
    6           Salvelinus malma         69.97  very high     2691
    7     Plectropomus leopardus         51.04  very high     4826
    8  Schizothorax richardsonii         34.78    unknown     8705
    9          Arripis truttacea         47.96    unknown    14606

### FishBase Docs: Discovering data

Unfortunately identifying what fields come from which tables is often a challenge. Each summary page on fishbase.org includes a list of additional tables with more information about species ecology, diet, occurrences, and many other things. `rfishbase` provides functions that correspond to most of these tables.

Because `rfishbase` accesses the back end database, it does not always line up with the web display. Frequently `rfishbase` functions will return more information than is available on the web versions of the these tables. Some information found on the summary homepage for a species is not available from the `species` summary function, but must be extracted from a different table. For instance, the species `Resilience` information is not one of the fields in the `species` summary table, despite appearing on the species homepage of fishbase.org. To discover which table this information is in, we can use the special `rfishbase` function `list_fields`, which will list all tables with a field matching the query string:

``` r
list_fields("Resilience")
```

    # A tibble: 2 x 2
      table_name      column_name
           <chr>            <chr>
    1     stocks       Resilience
    2     stocks ResilienceRemark

This shows us that this information appears on the `stocks` table. Working in R, it is easy to query this additional table and combine the results with the data we have collected so far:

``` r
resil <- stocks(fish, fields="Resilience")
merge(dat, resil)
```

                          sciname SpecCode Vulnerability PriceCateg Resilience
    1           Arripis truttacea    14606         47.96    unknown     Medium
    2          Lethrinus miniatus     1858         52.78  very high     Medium
    3         Oncorhynchus mykiss      239         36.29        low     Medium
    4      Plectropomus leopardus     4826         51.04  very high     Medium
    5                Salmo trutta      238         59.96  very high       High
    6                Salmo trutta      238         59.96  very high       <NA>
    7                Salmo trutta      238         59.96  very high     Medium
    8                Salmo trutta      238         59.96  very high        Low
    9                Salmo trutta      238         59.96  very high       <NA>
    10               Salmo trutta      238         59.96  very high       <NA>
    11               Salmo trutta      238         59.96  very high       <NA>
    12 Salvelinus alpinus alpinus      247         74.33  very high        Low
    13      Salvelinus fontinalis      246         43.37  very high     Medium
    14           Salvelinus malma     2691         69.97  very high        Low
    15           Salvelinus malma     2691         69.97  very high       <NA>
    16  Schizothorax richardsonii     8705         34.78    unknown     Medium

Sometimes it is more useful to search for a broad description of the tables.

SeaLifeBase
-----------

The FishBase team has also created the SeaLifeBase project, which seeks to provide much the same data and layout as fishbase.org and the fishbase schema, but covering all sea life apart from the finfish covered in FishBase. The rOpenSci team has created a pilot API for SeaLifeBase as well. Most of the functions in `rfishbase` can be used directly to query SeaLifeBase data by explicitly specifying the `server` argument to use the SeaLifeBase API at `http://fishbase.ropensci.org/sealifebase`, like so:

``` r
options(FISHBASE_API = "http://fishbase.ropensci.org/sealifebase")
kingcrab <- common_to_sci("king crab")
kingcrab
```

``` r
species(kingcrab)
ecology(kingcrab)
```

Set the API back to `fishbase` for finfish data:

``` r
options(FISHBASE_API = "http://fishbase.ropensci.org")
```

------------------------------------------------------------------------

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

[![ropensci\_footer](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
