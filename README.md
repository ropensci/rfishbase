
# rfishbase <img src="man/figures/logo.svg" align="right" alt="" width="120" />

[![Build
Status](https://travis-ci.org/ropensci/rfishbase.svg)](https://travis-ci.org/ropensci/rfishbase)
[![Build
status](https://ci.appveyor.com/api/projects/status/decpqq5s57b7b0t6/branch/master?svg=true)](https://ci.appveyor.com/project/cboettig/rfishbase/branch/master)
[![cran
checks](https://cranchecks.info/badges/worst/rfishbase)](https://cranchecks.info/pkgs/rfishbase)
[![Coverage
status](https://codecov.io/gh/ropensci/rfishbase/branch/master/graph/badge.svg)](https://codecov.io/github/ropensci/rfishbase?branch=master)
[![Onboarding](https://badges.ropensci.org/137_status.svg)](https://github.com/ropensci/onboarding/issues/137)
[![CRAN
status](https://www.r-pkg.org/badges/version/rfishbase)](https://cran.r-project.org/package=rfishbase)
[![Downloads](http://cranlogs.r-pkg.org/badges/grand-total/rfishbase)](https://github.com/metacran/cranlogs.app)


Welcome to `rfishbase 3.0`. This package is the third rewrite of the
original `rfishbase` package described in [Boettiger et al.
(2012)](http://www.carlboettiger.info/assets/files/pubs/10.1111/j.1095-8649.2012.03464.x.pdf).

`rfishbase` 3.0 queries pre-compressed tables from a static server and
employs local caching (through memoization) to provide much greater
performance and stability, particularly for dealing with large queries
involving 10s of thousands of species. The user is never expected to
deal with pagination or curl headers and timeouts.

We welcome any feedback, issues or questions that users may encounter
through our issues tracker on GitHub:
<https://github.com/ropensci/rfishbase/issues>

## Installation

``` r
remotes::install_github("ropensci/rfishbase")
```

``` r
library("rfishbase")
library("dplyr") # convenient but not required
```

## Getting started

[FishBase](http://fishbase.org) makes it relatively easy to look up a
lot of information on most known species of fish. However, looking up a
single bit of data, such as the estimated trophic level, for many
different species becomes tedious very soon. This is a common reason for
using `rfishbase`. As such, our first step is to assemble a good list of
species we are interested in.

### Building a species list

Almost all functions in `rfishbase` take a list (character vector) of
species scientific names, for example:

``` r
fish <- c("Oreochromis niloticus", "Salmo trutta")
```

You can also read in a list of names from any existing data you are
working with. When providing your own species list, you should always
begin by validating the names. Taxonomy is a moving target, and this
well help align the scientific names you are using with the names used
by FishBase, and alert you to any potential issues:

``` r
fish <- validate_names(c("Oreochromis niloticus", "Salmo trutta"))
```

Another typical use case is in wanting to collect information about all
species in a particular taxonomic group, such as a Genus, Family or
Order. The function `species_list` recognizes six taxonomic levels, and
can help you generate a list of names of all species in a given group:

``` r
fish <- species_list(Genus = "Labroides")
fish
```

    [1] "Labroides dimidiatus"    "Labroides bicolor"      
    [3] "Labroides pectoralis"    "Labroides phthirophagus"
    [5] "Labroides rubrolabiatus"

`rfishbase` also recognizes common names. When a common name refers to
multiple species, all matching species are returned:

``` r
trout <- common_to_sci("trout")
trout
```

    # A tibble: 279 x 4
       Species                   ComName              Language SpecCode
       <chr>                     <chr>                <chr>       <dbl>
     1 Salmo obtusirostris       Adriatic trout       English      6210
     2 Schizothorax richardsonii Alawan snowtrout     English      8705
     3 Schizopyge niger          Alghad snowtrout     English     24454
     4 Salvelinus fontinalis     American brook trout English       246
     5 Salmo trutta              Amu-Darya trout      English       238
     6 Oncorhynchus apache       Apache Trout         English      2687
     7 Oncorhynchus apache       Apache trout         English      2687
     8 Plectropomus areolatus    Apricot trout        English      6082
     9 Salmo trutta              Aral Sea Trout       English       238
    10 Salmo trutta              Aral trout           English       238
    # … with 269 more rows

Note that there is no need to validate names coming from `common_to_sci`
or `species_list`, as these will always return valid names.

### Getting data

With a species list in place, we are ready to query fishbase for data.
Note that if you have a very long list of species, it is always a good
idea to try out your intended functions with a subset of that list first
to make sure everything is working.

The `species()` function returns a table containing much (but not all)
of the information found on the summary or homepage for a species on
[fishbase.org](http://fishbase.org). `rfishbase` functions always return
[tidy](http://www.jstatsoft.org/v59/i10/paper) data tables: rows are
observations (e.g. a species, individual samples from a species) and
columns are variables (fields).

``` r
species(trout$Species)
```

    # A tibble: 279 x 98
       SpecCode Species SpeciesRefNo Author FBname PicPreferredName
          <dbl> <chr>          <dbl> <chr>  <chr>  <chr>           
     1     6210 Salmo …        59043 (Heck… Adria… Saobt_u0.jpg    
     2     8705 Schizo…         4832 (Gray… Snowt… Scric_u1.jpg    
     3    24454 Schizo…         4832 (Heck… Algha… <NA>            
     4      246 Salvel…         5723 (Mitc… Brook… Safon_u4.jpg    
     5      238 Salmo …         4779 Linna… Sea t… Satru_u2.jpg    
     6     2687 Oncorh…         5723 (Mill… Apach… Onapa_u0.jpg    
     7     2687 Oncorh…         5723 (Mill… Apach… Onapa_u0.jpg    
     8     6082 Plectr…         5222 (R<fc… Squar… Plare_u4.jpg    
     9      238 Salmo …         4779 Linna… Sea t… Satru_u2.jpg    
    10      238 Salmo …         4779 Linna… Sea t… Satru_u2.jpg    
    # … with 269 more rows, and 92 more variables: PicPreferredNameM <chr>,
    #   PicPreferredNameF <chr>, PicPreferredNameJ <chr>, FamCode <dbl>,
    #   Subfamily <chr>, GenCode <dbl>, SubGenCode <dbl>, BodyShapeI <chr>,
    #   Source <chr>, AuthorRef <lgl>, Remark <chr>, TaxIssue <dbl>,
    #   Fresh <dbl>, Brack <dbl>, Saltwater <dbl>, DemersPelag <chr>,
    #   AnaCat <chr>, MigratRef <dbl>, DepthRangeShallow <dbl>,
    #   DepthRangeDeep <dbl>, DepthRangeRef <dbl>, DepthRangeComShallow <dbl>,
    #   DepthRangeComDeep <dbl>, DepthComRef <dbl>, LongevityWild <dbl>,
    #   LongevityWildRef <dbl>, LongevityCaptive <dbl>, LongevityCapRef <dbl>,
    #   Vulnerability <dbl>, Length <dbl>, LTypeMaxM <chr>,
    #   LengthFemale <dbl>, LTypeMaxF <chr>, MaxLengthRef <dbl>,
    #   CommonLength <dbl>, LTypeComM <chr>, CommonLengthF <dbl>,
    #   LTypeComF <chr>, CommonLengthRef <dbl>, Weight <dbl>,
    #   WeightFemale <dbl>, MaxWeightRef <dbl>, Pic <chr>,
    #   PictureFemale <chr>, LarvaPic <chr>, EggPic <chr>,
    #   ImportanceRef <dbl>, Importance <chr>, PriceCateg <chr>,
    #   PriceReliability <chr>, Remarks7 <chr>, LandingStatistics <chr>,
    #   Landings <chr>, MainCatchingMethod <chr>, II <chr>, MSeines <dbl>,
    #   MGillnets <dbl>, MCastnets <dbl>, MTraps <dbl>, MSpears <dbl>,
    #   MTrawls <dbl>, MDredges <dbl>, MLiftnets <dbl>, MHooksLines <dbl>,
    #   MOther <dbl>, UsedforAquaculture <chr>, LifeCycle <chr>,
    #   AquacultureRef <dbl>, UsedasBait <chr>, BaitRef <dbl>, Aquarium <chr>,
    #   AquariumFishII <chr>, AquariumRef <dbl>, GameFish <dbl>,
    #   GameRef <dbl>, Dangerous <chr>, DangerousRef <dbl>,
    #   Electrogenic <chr>, ElectroRef <dbl>, Complete <lgl>,
    #   GoogleImage <dbl>, Comments <chr>, Profile <chr>, PD50 <dbl>,
    #   Emblematic <dbl>, Entered <dbl>, DateEntered <dttm>, Modified <dbl>,
    #   DateModified <dttm>, Expert <dbl>, DateChecked <dttm>, TS <lgl>

Most tables contain many fields. To avoid overly cluttering the screen,
`rfishbase` displays tables as “tibbles” from the `dplyr` package. These
act just like the familiar `data.frames` of base R except that they
print to the screen in a more tidy fashion. Note that columns that
cannot fit easily in the display are summarized below the table. This
gives us an easy way to see what fields are available in a given table.

Most `rfishbase` functions will let the user subset these fields by
listing them in the `fields` argument, for
instance:

``` r
dat <- species(trout$Species, fields=c("Species", "PriceCateg", "Vulnerability"))
dat
```

    # A tibble: 279 x 3
       Species                   PriceCateg Vulnerability
       <chr>                     <chr>              <dbl>
     1 Salmo obtusirostris       very high           47.0
     2 Schizothorax richardsonii unknown             34.8
     3 Schizopyge niger          unknown             46.8
     4 Salvelinus fontinalis     very high           43.4
     5 Salmo trutta              very high           60.0
     6 Oncorhynchus apache       very high           53.8
     7 Oncorhynchus apache       very high           53.8
     8 Plectropomus areolatus    very high           57.0
     9 Salmo trutta              very high           60.0
    10 Salmo trutta              very high           60.0
    # … with 269 more rows

Alternatively, just subset the table using the standard column selection
in base R (`[[`) or `dplyr::select`.

### FishBase Docs: Discovering data

Unfortunately identifying what fields come from which tables is often a
challenge. Each summary page on fishbase.org includes a list of
additional tables with more information about species ecology, diet,
occurrences, and many other things. `rfishbase` provides functions that
correspond to most of these tables.

Because `rfishbase` accesses the back end database, it does not always
line up with the web display. Frequently `rfishbase` functions will
return more information than is available on the web versions of the
these tables. Some information found on the summary homepage for a
species is not available from the `species` summary function, but must
be extracted from a different table. For instance, the species
`Resilience` information is not one of the fields in the `species`
summary table, despite appearing on the species homepage of
fishbase.org. To discover which table this information is in, we can use
the special `rfishbase` function `list_fields`, which will list all
tables with a field matching the query string:

``` r
list_fields("Resilience")
```

    # A tibble: 1 x 1
      table 
      <chr> 
    1 stocks

This shows us that this information appears on the `stocks` table. We
can then request this data from the stocks table:

``` r
stocks(trout$Species, fields=c("Species", "Resilience", "StockDefs"))
```

    # A tibble: 380 x 3
       Species           Resilience StockDefs                                  
       <chr>             <chr>      <chr>                                      
     1 Salmo obtusirost… Medium     Europe:  Adriatic basin in Krka, Jardo, Vr…
     2 Schizothorax ric… Medium     Asia:  Himalayan region of India, Sikkim a…
     3 Schizopyge niger  Medium     Asia:  Kashmir Valley in India and Azad Ka…
     4 Salvelinus fonti… Medium     North America:  most of eastern Canada fro…
     5 Salmo trutta      High       Europe and Asia:  Atlantic, North, White a…
     6 Salmo trutta      <NA>       <i>Salmo trutta aralensis</i>:  Asia:  end…
     7 Salmo trutta      Medium     <i>Salmo trutta fario</i>:  Northeast  Atl…
     8 Salmo trutta      Low        "<i>Salmo trutta lacustris</i>\t:  Europe:…
     9 Salmo trutta      <NA>       "<i>Salmo trutta oxianus</i>\t:  Asia:  Am…
    10 Salmo trutta      <NA>       <i>Salmo trutta aralensis</i>:  Asia:  Ara…
    # … with 370 more rows

## Version stability

`rfishbase` relies on periodic cache releases. The current database
release is `17.07` (i.e. dating from July 2017). Set the version of
FishBase you wish to access by setting the environmental variable:

``` r
Sys.setenv(FISHBASE_VERSION="17.07")
```

Note that the same version number applies to both the `fishbase` and
`sealifebase` data. Stay tuned for new releases.

## SeaLifeBase

SeaLifeBase.org is maintained by the same organization and largely
parallels the database structure of Fishbase. As such, almost all
`rfishbase` functions can instead be instructed to address the

We can begin by getting the taxa table for sealifebase:

``` r
sealife <- load_taxa(server="sealifebase")
```

(Note: running `load_taxa()` at the beginning of any session, for either
fishbase or sealifebase is a good way to “warm up” rfishbase by loading
in taxonomic data it will need. This information is cached throughout
your session and will make all subsequent commands run faster. But no
worries if you skip this step, `rfishbase` will peform it for you on the
first time it is needed, and will cache these results thereafter.)

Let’s look at some Gastropods:

``` r
sealife %>% filter(Class == "Gastropoda")
```

    # A tibble: 19,473 x 9
       SpecCode Species    Genus  Subfamily Family  Order  Class Phylum Kingdom
          <dbl> <chr>      <chr>  <chr>     <chr>   <chr>  <chr> <chr>  <chr>  
     1       57 Salinator… Salin… <NA>      Amphib… Pulmo… Gast… Mollu… Animal…
     2       58 Tasmaphen… Tasma… <NA>      Rhytid… Pulmo… Gast… Mollu… Animal…
     3       59 Tasmaphen… Tasma… <NA>      Rhytid… Pulmo… Gast… Mollu… Animal…
     4       60 Torresiro… Torre… <NA>      Rhytid… Pulmo… Gast… Mollu… Animal…
     5       61 Victaphan… Victa… <NA>      Rhytid… Pulmo… Gast… Mollu… Animal…
     6       62 Victaphan… Victa… <NA>      Rhytid… Pulmo… Gast… Mollu… Animal…
     7       63 Victaphan… Victa… <NA>      Rhytid… Pulmo… Gast… Mollu… Animal…
     8       64 Victaphan… Victa… <NA>      Rhytid… Pulmo… Gast… Mollu… Animal…
     9       65 Anoglypta… Anogl… <NA>      Caryod… Pulmo… Gast… Mollu… Animal…
    10       66 Brazieres… Brazi… <NA>      Caryod… Pulmo… Gast… Mollu… Animal…
    # … with 19,463 more rows

All other tables can also take an argument to `server`:

``` r
species(server="sealifebase")
```

    # A tibble: 119,074 x 104
       SpecCode Species SpeciesRefNo Author AuthorRef FBname PicPreferredName
          <dbl> <chr>          <dbl> <chr>      <dbl> <chr>  <chr>           
     1        1 Phoron…            1 Wrigh…        NA <NA>   <NA>            
     2        2 Phoron…          997 Wrigh…        NA <NA>   <NA>            
     3        3 Phoron…            1 Oka, …        NA <NA>   <NA>            
     4        4 Phoron…            1 Haswe…        NA <NA>   Phaus_u0.jpg    
     5        5 Phoron…          997 Selys…        NA <NA>   <NA>            
     6        6 Phoron…            1 Cori,…        NA phoro… <NA>            
     7        7 Phoron…            1 (Schn…        NA <NA>   <NA>            
     8        8 Phoron…            1 Gilch…        NA <NA>   <NA>            
     9        9 Phoron…            1 Pixel…        NA <NA>   <NA>            
    10       10 Phoron…            1 Hilto…        NA Calif… <NA>            
    # … with 119,064 more rows, and 97 more variables:
    #   PicPreferredNameM <chr>, PicPreferredNameF <chr>,
    #   PicPreferredNameJ <chr>, FamCode <dbl>, Subfamily <chr>, Source <chr>,
    #   Remark <chr>, TaxIssue <dbl>, Fresh <dbl>, Brack <dbl>,
    #   Saltwater <dbl>, Land <dbl>, DemersPelag <chr>, AnaCat <chr>,
    #   MigratRef <dbl>, DepthRangeShallow <dbl>, DepthRangeDeep <dbl>,
    #   DepthRangeRef <dbl>, DepthRangeComShallow <dbl>,
    #   DepthRangeComDeep <dbl>, DepthComRef <dbl>, LongevityWild <dbl>,
    #   LongevityWildRef <dbl>, LongevityCaptive <lgl>, LongevityCapRef <lgl>,
    #   Vulnerability <dbl>, Length <dbl>, LTypeMaxM <chr>,
    #   LengthFemale <dbl>, LTypeMaxF <chr>, MaxLengthRef <dbl>,
    #   CommonLength <dbl>, LTypeComM <chr>, CommonLengthF <dbl>,
    #   LTypeComF <chr>, CommonLengthRef <dbl>, Weight <dbl>,
    #   WeightFemale <dbl>, MaxWeightRef <dbl>, Pic <lgl>,
    #   PictureFemale <lgl>, LarvaPic <lgl>, EggPic <lgl>,
    #   ImportanceRef <dbl>, Importance <chr>, Remarks7 <chr>,
    #   PriceCateg <chr>, PriceReliability <chr>, LandingStatistics <chr>,
    #   Landings <chr>, MainCatchingMethod <chr>, II <chr>, MSeines <dbl>,
    #   MGillnets <dbl>, MCastnets <dbl>, MTraps <dbl>, MSpears <dbl>,
    #   MTrawls <dbl>, MDredges <dbl>, MLiftnets <dbl>, MHooksLines <dbl>,
    #   MOther <dbl>, UsedforAquaculture <chr>, LifeCycle <chr>,
    #   AquacultureRef <dbl>, UsedasBait <chr>, BaitRef <dbl>, Aquarium <chr>,
    #   AquariumFishII <chr>, AquariumRef <dbl>, GameFish <dbl>,
    #   GameRef <lgl>, Dangerous <chr>, DangerousRef <dbl>,
    #   Electrogenic <chr>, ElectroRef <dbl>, Complete <lgl>, ASFA <lgl>,
    #   GoogleImage <dbl>, Entered <dbl>, DateEntered <dttm>, Modified <dbl>,
    #   DateModified <dttm>, Expert <dbl>, DateChecked <dttm>, Synopsis <lgl>,
    #   DateSynopsis <lgl>, Flag <lgl>, Comments <chr>,
    #   VancouverAquarium <dbl>, Profile <lgl>, Sp2000_NameCode <chr>,
    #   Sp2000_HierarchyCode <chr>, Sp2000_AuthorRefNumber <chr>,
    #   E_Append <dbl>, E_DateAppend <date>, TS <dttm>

CAUTION: if switching between `fishbase` and `sealifebase` in a single R
session, we strongly advise you always set `server` explicitly in your
function calls. Otherwise you may confuse the caching system.

## Backwards compatibility

`rfishbase` 3.0 tries to maintain as much backwards compatibility as
possible with rfishbase 2.0. However, there are cases in which the
rfishbase 2.0 behavior was not desirable – such as throwing errors when
a introducing simple `NA`s for missing data would be more appropriate,
or returning vectors where `data.frame`s were needed to include all the
context.

  - Argument names have been retained where possible to maximize
    backwards compatibility. Using previous arguments that are no longer
    relevant (such as `limit` for the maximum number of records) will
    not now introduce errors, but nor will they have any effect (they
    are simply consumed by the `...`). There are no longer any limits in
    return sizes.

  - You can still specify server using the rfishbase `2.x` format of
    providing a URL argument for server, e.g.
    `"http://fishbase.ropensci.org/sealifebase"` or
    `Sys.setenv(FISHBASE_API =
    "http://fishbase.ropensci.org/sealifebase")`, or simply
    `Sys.setenv("FISHBASE_API" = "sealifebase")` if you prefer. Also
    recall that environmental variables can always be set in an
    `.Renviron` file.

-----

Please note that this project is released with a [Contributor Code of
Conduct](CONDUCT.md). By participating in this project you agree to
abide by its
terms.

[![ropensci\_footer](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
