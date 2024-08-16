
# rfishbase <img src="man/figures/logo.svg" align="right" alt="" width="120" />

<!-- badges: start -->

[![R-CMD-check](https://github.com/ropensci/rfishbase/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ropensci/rfishbase/actions/workflows/R-CMD-check.yaml)
[![Coverage
status](https://codecov.io/gh/ropensci/rfishbase/branch/master/graph/badge.svg)](https://codecov.io/github/ropensci/rfishbase?branch=master)
[![Onboarding](https://badges.ropensci.org/137_status.svg)](https://github.com/ropensci/software-review/issues/137)
[![CRAN
status](https://www.r-pkg.org/badges/version/rfishbase)](https://cran.r-project.org/package=rfishbase)
[![Downloads](https://cranlogs.r-pkg.org/badges/grand-total/rfishbase)](https://github.com/r-hub/cranlogs.app)
<!-- badges: end -->

Welcome to `rfishbase 5`! This is the fourth rewrite of the original
`rfishbase` package described in [Boettiger et
al. (2012)](https://doi.org/10.1111/j.1095-8649.2012.03464.x).

Another streamlined re-design following new abilities for data hosting
and access. This release relies on a HuggingFace datasets hosting for
data and metadata hosting in parquet and schema.org.

Data access is simplified to use the simple HuggingFace datasets API
instead of the previous contentid-based resolution. This allows metadata
to be defined with directly alongside the data platform independent of
the R package.

A simplified access protocol relies on `duckdbfs` for direct reads of
tables. Several functions previously used only to manage connections are
now deprecated or removed, along with a significant number of
dependencies.

Core use still centers around the same package API using the `fb_tbl()`
function, with legacy helper functions for common tables like
`species()` are still accessible and can still optionally filter by
species name where appropriate. As before, loading the full tables and
sub-setting manually is still recommended.

Historic helper functions like `load_taxa()` (combining the taxonomic
classification from Species, Genus, Family and Order tables),
`validate_names()`, and `common_to_sci()` and `sci_to_common()` should
be in working order, all using table-based outputs.

- `rfishbase 1.0` relied on parsing of XML pages served directly from
  Fishbase.org.  
- `rfishbase 2.0` relied on calls to a ruby-based API, `fishbaseapi`,
  that provided access to SQL snapshots of about 20 of the more popular
  tables in FishBase or SeaLifeBase.
- `rfishbase 3.0` side-stepped the API by making queries which directly
  downloaded compressed csv tables from a static web host. This
  substantially improved performance a reliability, particularly for
  large queries. The release largely remained backwards compatible with
  2.0, and added more tables.
- `rfishbase 4.0` extends the static model and interface. Static tables
  are distributed in parquet and accessed through a provenance-based
  identifier. While old functions are retained, a new interface is
  introduced to provide easy access to all fishbase tables.

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

## Generic table interface

All fishbase tables can be accessed by name using the `fb_tbl()`
function:

``` r
fb_tbl("ecosystem")
```

    # A tibble: 160,334 × 18
       autoctr E_CODE EcosystemRefno Speccode Stockcode Status CurrentPresence
         <int>  <int>          <int>    <int>     <int> <chr>  <chr>          
     1       1      1          50628      549       565 native Present        
     2       2      1            189      552       568 native Present        
     3       3      1            189      554       570 native Present        
     4       4      1          79732      873       889 native Present        
     5       5      1           5217      948       964 native Present        
     6       7      1          39852      956       972 native Present        
     7       8      1          39852      957       973 native Present        
     8       9      1          39852      958       974 native Present        
     9      10      1            188     1526      1719 native Present        
    10      11      1            188     1626      1819 native Present        
    # ℹ 160,324 more rows
    # ℹ 11 more variables: Abundance <chr>, LifeStage <chr>, Remarks <chr>,
    #   Entered <int>, Dateentered <dttm>, Modified <int>, Datemodified <dttm>,
    #   Expert <int>, Datechecked <dttm>, WebURL <chr>, TS <dttm>

You can see all the tables using `fb_tables()` to see a list of all the
table names (specify `sealifebase` if desired). Careful, there are a lot
of them! The fishbase databases have grown a lot in the decades, and
were not intended to be used directly by most end-users, so you may have
considerable work to determine what’s what. Keep in mind that many
variables can be estimated in different ways (e.g. trophic level), and
thus may report different values in different tables. Also note that
species is name (or SpecCode) is not always the primary key for a table
– many tables are specific to stocks or even individual samples, and
some tables are reference lists that are not species focused at all, but
meant to be joined to other tables (`faoareas`, etc). Compare tables
against what you see on fishbase.org, or ask on our issues forum for
advice!

``` r
fish <- c("Oreochromis niloticus", "Salmo trutta")

fb_tbl("species") %>% 
  mutate(sci_name = paste(Genus, Species)) %>%
  filter(sci_name %in% fish) %>% 
  select(sci_name, FBname, Length)
```

    # A tibble: 2 × 3
      sci_name              FBname       Length
      <chr>                 <chr>         <dbl>
    1 Oreochromis niloticus Nile tilapia     60
    2 Salmo trutta          Sea trout       140

In most tables, species are identified by `SpecCode` (as per best
practices) rather than scientific names. Multiple tables can be joined
on the `SpecCode` to more fully describe a species.

To filter species by taxonomic names, use the taxa table from
`load_taxa()`, which provides a joined table of taxonomy from subspecies
up through Class, along with the corresponding FishBase taxon ids codes.
Here is an example workflow joining two of the spawing tables and
filtering to the grouper family, *Epinephelidae*:

``` r
library(rfishbase)
library(dplyr)

## Get the whole spawning and spawn agg table, joined together:
spawn <- left_join(fb_tbl("spawning"),  
                   fb_tbl("spawnagg"), 
                   relationship = "many-to-many")

# Filter taxa down to the desired species
groupers <- load_taxa() |> filter(Family == "Epinephelidae")

## A "filtering join" (inner join) 
spawn |> inner_join(groupers)
```

    # A tibble: 227 × 95
       autoctr StockCode SpecCode SpawningRefNo SourceRef C_Code E_CODE
         <int>     <int>    <int>         <int>     <int> <chr>   <int>
     1      18        18       12          5222      3092 528A       NA
     2      19        18       12         26409      1784 388       145
     3      20        20       14         26409        NA 192        NA
     4    9147        20       14        118249    118249 826E        8
     5      22        21       15          5241      5241 630        NA
     6      23        21       15          5241      6484 388        NA
     7      24        21       15          5241      3095 060        NA
     8      24        21       15          5241      3095 060        NA
     9      24        21       15          5241      3095 060        NA
    10      24        21       15          5241      3095 060        NA
    # ℹ 217 more rows
    # ℹ 88 more variables: SpawningGround <chr>, Spawningarea <chr>, Jan <dbl>,
    #   Feb <dbl>, Mar <dbl>, Apr <dbl>, May <dbl>, Jun <dbl>, Jul <dbl>,
    #   Aug <dbl>, Sep <dbl>, Oct <dbl>, Nov <dbl>, Dec <dbl>, GSI <int>,
    #   PercentFemales <int>, TempLow <dbl>, TempHigh <dbl>, SexRatiomid <dbl>,
    #   SexRmodRef <int>, FecundityMin <int>, WeightMin <dbl>,
    #   LengthFecunMin <dbl>, LengthTypeFecMin <chr>, FecundityRef <int>, …

## Species Names

Always keep in mind that taxonomy is a dynamic concept. Species can be
split or lumped based on new evidence, and naming authorities can
disagree over which name is an ‘accepted name’ or ‘synonym’ for any
given species. When providing your own list of species names, consider
first checking that those names are “valid” in the current taxonomy
established by FishBase:

``` r
validate_names("Abramites ternetzi")
```

    [1] "Abramites hypselonotus"

`rfishbase` can also provide tables of `synonyms()`, a table of
`common_names()` in multiple languages, and convert `common_to_sci()` or
`sci_to_common()`

``` r
common_to_sci(c("Bicolor cleaner wrasse", "humphead parrotfish"), Language="English")
```

    # A tibble: 5 × 4
      Species                ComName                     Language SpecCode
      <chr>                  <chr>                       <chr>       <int>
    1 Labroides bicolor      Bicolor cleaner wrasse      English      5650
    2 Chlorurus cyanescens   Blue humphead parrotfish    English      7909
    3 Bolbometopon muricatum Green humphead parrotfish   English      5537
    4 Bolbometopon muricatum Humphead parrotfish         English      5537
    5 Chlorurus oedema       Uniform humphead parrotfish English      8394

Note that the results are returned as a table, potentially indicating
other common names for the same species, as well as potentially
different species that match the provided common name! Please always be
careful with names, and use unique SpecCodes to refer to unique species.

## SeaLifeBase

SeaLifeBase.org is maintained by the same organization and largely
parallels the database structure of Fishbase. As such, almost all
`rfishbase` functions can instead be instructed to address the

``` r
fb_tbl("species", "sealifebase")
```

    # A tibble: 102,464 × 111
       SpecCode Genus   Species Author SpeciesRefNo FBname FamCode Subfamily GenCode
          <int> <chr>   <chr>   <chr>         <int> <chr>    <int> <chr>       <int>
     1    57969 Abdopus horrid… (D'Or…        96968 Red S…    1890 Octopodi…   24384
     2    57836 Abdopus tenebr… (Smit…           19 <NA>      1890 Octopodi…   24384
     3    57142 Abdopus tongan… (Hoyl…           19 <NA>      1890 Octopodi…   24384
     4  2381155 Abdopus undula… Huffa…        84307 <NA>      1890 <NA>        24384
     5    14647 Abebai… troglo… Vande…           19 <NA>       572 <NA>         9260
     6   165283 Aberom… muranoi Baces…       104101 <NA>       616 <NA>        33537
     7   140720 Aberra… banyul… Macki…        85340 <NA>       174 <NA>         9262
     8    40346 Aberra… enigma… unspe…           19 <NA>       174 <NA>         9262
     9    20199 Aberra… aberra… (Barn…           19 <NA>       308 <NA>         9263
    10    93706 Aberro… verruc… Kasat…         3696 <NA>       922 <NA>        17969
    # ℹ 102,454 more rows
    # ℹ 102 more variables: TaxIssue <int>, Remark <chr>, PicPreferredName <chr>,
    #   PicPreferredNameM <chr>, PicPreferredNameF <chr>, PicPreferredNameJ <chr>,
    #   Source <chr>, AuthorRef <int>, SubGenCode <int>, Fresh <int>, Brack <int>,
    #   Saltwater <int>, Land <int>, BodyShapeI <chr>, DemersPelag <chr>,
    #   Amphibious <chr>, AmphibiousRef <int>, AnaCat <chr>, MigratRef <int>,
    #   DepthRangeShallow <int>, DepthRangeDeep <int>, DepthRangeRef <int>, …

## Versions and importing all tables

By default, tables are downloaded the first time they are used.
`rfishbase` defaults to download the latest available snapshot; be aware
that the most recent snapshot may be months behind the latest data on
fishbase.org. Check available releases:

``` r
available_releases()
```

    [1] "19.04" "21.06" "23.01" "23.05" "24.07"

------------------------------------------------------------------------

Please note that this package is released with a [Contributor Code of
Conduct](https://ropensci.org/code-of-conduct/). By contributing to this
project, you agree to abide by its terms.

[![ropensci_footer](https://ropensci.org/public_images/github_footer.png)](https://ropensci.org)
