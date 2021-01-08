
# rfishbase <img src="man/figures/logo.svg" align="right" alt="" width="120" />

[![R-check](https://github.com/ropensci/rfishbase/workflows/R-check/badge.svg)](https://github.com/ropensci/rfishbase/actions?query=workflow%3AR-check)
[![cran
checks](https://cranchecks.info/badges/worst/rfishbase)](https://cranchecks.info/pkgs/rfishbase)
[![Coverage
status](https://codecov.io/gh/ropensci/rfishbase/branch/master/graph/badge.svg)](https://codecov.io/github/ropensci/rfishbase?branch=master)
[![Onboarding](https://badges.ropensci.org/137_status.svg)](https://github.com/ropensci/software-review/issues/137)
[![CRAN
status](https://www.r-pkg.org/badges/version/rfishbase)](https://cran.r-project.org/package=rfishbase)
[![Downloads](https://cranlogs.r-pkg.org/badges/grand-total/rfishbase)](https://github.com/r-hub/cranlogs.app)

Welcome to `rfishbase 3.0`. This package is the third rewrite of the
original `rfishbase` package described in [Boettiger et
al. (2012)](https://doi.org/10.1111/j.1095-8649.2012.03464.x).

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

[FishBase](https://fishbase.org) makes it relatively easy to look up a
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

    [1] "Labroides bicolor"       "Labroides dimidiatus"   
    [3] "Labroides pectoralis"    "Labroides phthirophagus"
    [5] "Labroides rubrolabiatus"

`rfishbase` also recognizes common names. When a common name refers to
multiple species, all matching species are returned:

``` r
trout <- common_to_sci("trout")
trout
```

    # A tibble: 305 x 4
       Species                   ComName              Language SpecCode
       <chr>                     <chr>                <chr>    <chr>   
     1 Salmo obtusirostris       Adriatic trout       English  6210    
     2 Schizothorax richardsonii Alawan snowtrout     English  8705    
     3 Schizopyge niger          Alghad snowtrout     English  24454   
     4 Salvelinus fontinalis     American brook trout English  246     
     5 Salmo trutta              Amu-Darya trout      English  238     
     6 Salmo kottelati           Antalya trout        English  67602   
     7 Oncorhynchus apache       Apache Trout         English  2687    
     8 Oncorhynchus apache       Apache trout         English  2687    
     9 Plectropomus areolatus    Apricot trout        English  6082    
    10 Salmo trutta              Aral Sea Trout       English  238     
    # … with 295 more rows

Note that there is no need to validate names coming from `common_to_sci`
or `species_list`, as these will always return valid names.

### Getting data

With a species list in place, we are ready to query fishbase for data.
Note that if you have a very long list of species, it is always a good
idea to try out your intended functions with a subset of that list first
to make sure everything is working.

The `species()` function returns a table containing much (but not all)
of the information found on the summary or homepage for a species on
[fishbase.org](https://fishbase.org). `rfishbase` functions always
return [tidy](https://www.jstatsoft.org/v59/i10/paper) data tables: rows
are observations (e.g. a species, individual samples from a species) and
columns are variables (fields).

``` r
species(trout$Species)
```

    # A tibble: 305 x 101
       SpecCode Species Genus SpeciesRefNo Author FBname PicPreferredName
       <chr>    <chr>   <chr> <chr>        <chr>  <chr>  <chr>           
     1 6210     Salmo … Salmo 59043        (Heck… Adria… Saobt_u0.jpg    
     2 8705     Schizo… Schi… 4832         (Gray… Snowt… Scric_u1.jpg    
     3 24454    Schizo… Schi… 4832         (Heck… Algha… <NA>            
     4 246      Salvel… Salv… 86798        (Mitc… Brook… Safon_u4.jpg    
     5 238      Salmo … Salmo 4779         Linna… Sea t… Satru_u2.jpg    
     6 67602    Salmo … Salmo 99540        Turan… Antal… Sakot_m0.jpg    
     7 2687     Oncorh… Onco… 5723         (Mill… Apach… Onapa_u0.jpg    
     8 2687     Oncorh… Onco… 5723         (Mill… Apach… Onapa_u0.jpg    
     9 6082     Plectr… Plec… 5222         (R<fc… Squar… Plare_u4.jpg    
    10 238      Salmo … Salmo 4779         Linna… Sea t… Satru_u2.jpg    
    # … with 295 more rows, and 94 more variables: PicPreferredNameM <chr>,
    #   PicPreferredNameF <chr>, PicPreferredNameJ <chr>, FamCode <chr>,
    #   Subfamily <chr>, GenCode <chr>, SubGenCode <chr>, BodyShapeI <chr>,
    #   Source <chr>, AuthorRef <chr>, Remark <chr>, TaxIssue <chr>, Fresh <chr>,
    #   Brack <chr>, Saltwater <chr>, DemersPelag <chr>, Amphibious <chr>,
    #   AmphibiousRef <chr>, AnaCat <chr>, MigratRef <chr>,
    #   DepthRangeShallow <chr>, DepthRangeDeep <chr>, DepthRangeRef <chr>,
    #   DepthRangeComShallow <chr>, DepthRangeComDeep <chr>, DepthComRef <chr>,
    #   LongevityWild <chr>, LongevityWildRef <chr>, LongevityCaptive <chr>,
    #   LongevityCapRef <chr>, Vulnerability <chr>, Length <chr>, LTypeMaxM <chr>,
    #   LengthFemale <chr>, LTypeMaxF <chr>, MaxLengthRef <chr>,
    #   CommonLength <chr>, LTypeComM <chr>, CommonLengthF <chr>, LTypeComF <chr>,
    #   CommonLengthRef <chr>, Weight <chr>, WeightFemale <chr>,
    #   MaxWeightRef <chr>, Pic <chr>, PictureFemale <chr>, LarvaPic <chr>,
    #   EggPic <chr>, ImportanceRef <chr>, Importance <chr>, PriceCateg <chr>,
    #   PriceReliability <chr>, Remarks7 <chr>, LandingStatistics <chr>,
    #   Landings <chr>, MainCatchingMethod <chr>, II <chr>, MSeines <chr>,
    #   MGillnets <chr>, MCastnets <chr>, MTraps <chr>, MSpears <chr>,
    #   MTrawls <chr>, MDredges <chr>, MLiftnets <chr>, MHooksLines <chr>,
    #   MOther <chr>, UsedforAquaculture <chr>, LifeCycle <chr>,
    #   AquacultureRef <chr>, UsedasBait <chr>, BaitRef <chr>, Aquarium <chr>,
    #   AquariumFishII <chr>, AquariumRef <chr>, GameFish <chr>, GameRef <chr>,
    #   Dangerous <chr>, DangerousRef <chr>, Electrogenic <chr>, ElectroRef <chr>,
    #   Complete <chr>, GoogleImage <chr>, Comments <chr>, Profile <chr>,
    #   PD50 <chr>, Emblematic <chr>, Entered <chr>, DateEntered <chr>,
    #   Modified <chr>, DateModified <chr>, Expert <chr>, DateChecked <chr>,
    #   TS <chr>

Most tables contain many fields. To avoid overly cluttering the screen,
`rfishbase` displays tables as “tibbles” from the `dplyr` package. These
act just like the familiar `data.frames` of base R except that they
print to the screen in a more tidy fashion. Note that columns that
cannot fit easily in the display are summarized below the table. This
gives us an easy way to see what fields are available in a given table.

Most `rfishbase` functions will let the user subset these fields by
listing them in the `fields` argument, for instance:

``` r
dat <- species(trout$Species, fields=c("Species", "PriceCateg", "Vulnerability"))
dat
```

    # A tibble: 305 x 3
       Species                   PriceCateg Vulnerability
       <chr>                     <chr>      <chr>        
     1 Salmo obtusirostris       very high  46.98        
     2 Schizothorax richardsonii unknown    34.78        
     3 Schizopyge niger          unknown    46.76        
     4 Salvelinus fontinalis     very high  43.37        
     5 Salmo trutta              very high  59.96        
     6 Salmo kottelati           <NA>       33.71        
     7 Oncorhynchus apache       very high  53.76        
     8 Oncorhynchus apache       very high  53.76        
     9 Plectropomus areolatus    very high  30.28        
    10 Salmo trutta              very high  59.96        
    # … with 295 more rows

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

    # A tibble: 407 x 3
       Species            Resilience StockDefs                                      
       <chr>              <chr>      <chr>                                          
     1 Salmo obtusirostr… Medium     "Europe:  Adriatic basin in Krka, Jardo, Vrlji…
     2 Schizothorax rich… Medium     "Asia:  Himalayan region of India, Sikkim and …
     3 Schizopyge niger   Medium     "Asia:  Kashmir Valley in India and Azad Kashm…
     4 Salvelinus fontin… Medium     "North America:  native to most of eastern Can…
     5 Salmo trutta       <NA>       "<i>Salmo trutta aralensis</i>:  Asia:  Aral S…
     6 Salmo trutta       <NA>       "<i>Salmo trutta aralensis</i>:  Asia:  endemi…
     7 Salmo trutta       Medium     "<i>Salmo trutta fario</i>:  Northeast  Atlant…
     8 Salmo trutta       Low        "<i>Salmo trutta lacustris</i>\t:  Europe:  wi…
     9 Salmo trutta       <NA>       "<i>Salmo trutta oxianus</i>\t:  Asia:  Amu-Da…
    10 Salmo trutta       <NA>       "Baltic Sea (ICES subdivisions 22-32)"         
    # … with 397 more rows

## Version stability

`rfishbase` relies on periodic cache releases. The current database
release is `17.07` (i.e. dating from July 2017). Set the version of
FishBase you wish to access by setting the environmental variable:

``` r
options(FISHBASE_VERSION="19.04")
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

    # Source:     lazy query [?? x 9]
    # Database:   sqlite 3.33.0
    #   [/home/cboettig/.local/share/rfishbase/database/sqlite_db.sqlite]
    # Ordered by: "SpecCode"
       SpecCode Species      Genus   Subfamily Family  Order   Class  Phylum Kingdom
       <chr>    <chr>        <chr>   <chr>     <chr>   <chr>   <chr>  <chr>  <chr>  
     1 139911   Barleeia go… Barlee… <NA>      Barlee… Neotae… Gastr… Mollu… Animal…
     2 139912   Barleeia se… Barlee… <NA>      Barlee… Neotae… Gastr… Mollu… Animal…
     3 141136   Amphithalam… Amphit… <NA>      Barlee… Neotae… Gastr… Mollu… Animal…
     4 141162   Barleeia me… Barlee… <NA>      Barlee… Neotae… Gastr… Mollu… Animal…
     5 141878   Amphithalam… Amphit… <NA>      Barlee… Neotae… Gastr… Mollu… Animal…
     6 141879   Amphithalam… Amphit… <NA>      Barlee… Neotae… Gastr… Mollu… Animal…
     7 147422   Lirobarleei… Liroba… <NA>      Barlee… Neotae… Gastr… Mollu… Animal…
     8 147532   Barleeia ru… Barlee… <NA>      Barlee… Neotae… Gastr… Mollu… Animal…
     9 148185   Barleeia cr… Barlee… <NA>      Barlee… Neotae… Gastr… Mollu… Animal…
    10 148186   Caelatura g… Caelat… <NA>      Barlee… Neotae… Gastr… Mollu… Animal…
    # … with more rows

All other tables can also take an argument to `server`:

``` r
species(server="sealifebase")
```

    # A tibble: 121,348 x 109
       SpecCode Species Genus Author SpeciesRefNo FBname FamCode Subfamily GenCode
       <chr>    <chr>   <chr> <chr>  <chr>        <chr>  <chr>   <chr>     <chr>  
     1 32307    Aaptol… Aapt… (Pils… 19           <NA>   815     <NA>      27838  
     2 32306    Aaptol… Aapt… Newma… 81749        <NA>   815     <NA>      27838  
     3 32308    Aaptol… Aapt… (Pils… 19           <NA>   815     <NA>      27838  
     4 32304    Aaptol… Aapt… Newma… 19           <NA>   815     <NA>      27838  
     5 32305    Aaptol… Aapt… Newma… 19           <NA>   815     <NA>      27838  
     6 51720    Aaptos… Aapt… (Schm… 19           <NA>   2630    <NA>      9253   
     7 165941   Aaptos… Aapt… de La… 108813       <NA>   2630    <NA>      <NA>   
     8 105687   Aaptos… Aapt… (Wils… 3477         <NA>   2630    <NA>      9253   
     9 10215    Aatola… Aato… (Mier… 3113         <NA>   521     <NA>      9254   
    10 90398    Aatola… Aato… Keabl… 3113         <NA>   521     <NA>      9254   
    # … with 121,338 more rows, and 100 more variables: TaxIssue <chr>,
    #   Remark <chr>, PicPreferredName <chr>, PicPreferredNameM <chr>,
    #   PicPreferredNameF <chr>, PicPreferredNameJ <chr>, Source <chr>,
    #   AuthorRef <chr>, SubGenCode <chr>, Fresh <chr>, Brack <chr>,
    #   Saltwater <chr>, Land <chr>, BodyShapeI <chr>, DemersPelag <chr>,
    #   AnaCat <chr>, MigratRef <chr>, DepthRangeShallow <chr>,
    #   DepthRangeDeep <chr>, DepthRangeRef <chr>, DepthRangeComShallow <chr>,
    #   DepthRangeComDeep <chr>, DepthComRef <chr>, LongevityWild <chr>,
    #   LongevityWildRef <chr>, LongevityCaptive <chr>, LongevityCapRef <chr>,
    #   Vulnerability <chr>, Length <chr>, LTypeMaxM <chr>, LengthFemale <chr>,
    #   LTypeMaxF <chr>, MaxLengthRef <chr>, CommonLength <chr>, LTypeComM <chr>,
    #   CommonLengthF <chr>, LTypeComF <chr>, CommonLengthRef <chr>, Weight <chr>,
    #   WeightFemale <chr>, MaxWeightRef <chr>, Pic <chr>, PictureFemale <chr>,
    #   LarvaPic <chr>, EggPic <chr>, ImportanceRef <chr>, Importance <chr>,
    #   Remarks7 <chr>, PriceCateg <chr>, PriceReliability <chr>,
    #   LandingStatistics <chr>, Landings <chr>, MainCatchingMethod <chr>,
    #   II <chr>, MSeines <chr>, MGillnets <chr>, MCastnets <chr>, MTraps <chr>,
    #   MSpears <chr>, MTrawls <chr>, MDredges <chr>, MLiftnets <chr>,
    #   MHooksLines <chr>, MOther <chr>, UsedforAquaculture <chr>, LifeCycle <chr>,
    #   AquacultureRef <chr>, UsedasBait <chr>, BaitRef <chr>, Aquarium <chr>,
    #   AquariumFishII <chr>, AquariumRef <chr>, GameFish <chr>, GameRef <chr>,
    #   Dangerous <chr>, DangerousRef <chr>, Electrogenic <chr>, ElectroRef <chr>,
    #   Complete <chr>, ASFA <chr>, GoogleImage <chr>, Emblematic <chr>,
    #   Entered <chr>, DateEntered <chr>, Modified <chr>, DateModified <chr>,
    #   Expert <chr>, DateChecked <chr>, Synopsis <chr>, DateSynopsis <chr>,
    #   Flag <chr>, Comments <chr>, VancouverAquarium <chr>, Profile <chr>,
    #   Sp2000_NameCode <chr>, Sp2000_HierarchyCode <chr>,
    #   Sp2000_AuthorRefNumber <chr>, E_Append <chr>, E_DateAppend <chr>, TS <chr>

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
    providing a URL argument for server,
    e.g. `"https://fishbase.ropensci.org/sealifebase"` or
    `Sys.setenv(FISHBASE_API =
    "https://fishbase.ropensci.org/sealifebase")`, or simply
    `Sys.setenv("FISHBASE_API" = "sealifebase")` if you prefer. Also
    recall that environmental variables can always be set in an
    `.Renviron` file.

-----

Please note that this package is released with a [Contributor Code of
Conduct](https://ropensci.org/code-of-conduct/). By contributing to this
project, you agree to abide by its terms.

[![ropensci\_footer](https://ropensci.org/public_images/github_footer.png)](https://ropensci.org)
