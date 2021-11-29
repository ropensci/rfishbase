
# rfishbase <img src="man/figures/logo.svg" align="right" alt="" width="120" />

<!-- badges: start -->

[![R-CMD-check](https://github.com/ropensci/rfishbase/workflows/R-CMD-check/badge.svg)](https://github.com/ropensci/rfishbase/actions)
[![cran
checks](https://cranchecks.info/badges/worst/rfishbase)](https://cranchecks.info/pkgs/rfishbase)
[![Coverage
status](https://codecov.io/gh/ropensci/rfishbase/branch/master/graph/badge.svg)](https://codecov.io/github/ropensci/rfishbase?branch=master)
[![Onboarding](https://badges.ropensci.org/137_status.svg)](https://github.com/ropensci/software-review/issues/137)
[![CRAN
status](https://www.r-pkg.org/badges/version/rfishbase)](https://cran.r-project.org/package=rfishbase)
[![Downloads](https://cranlogs.r-pkg.org/badges/grand-total/rfishbase)](https://github.com/r-hub/cranlogs.app)
<!-- badges: end -->

Welcome to `rfishbase 4`. This is the fourth rewrite of the original
`rfishbase` package described in [Boettiger et
al. (2012)](https://doi.org/10.1111/j.1095-8649.2012.03464.x).

-   `rfishbase 1.0` relied on parsing of XML pages served directly from
    Fishbase.org.  
-   `rfishbase 2.0` relied on calls to a ruby-based API, `fishbaseapi`,
    that provided access to SQL snapshots of about 20 of the more
    popular tables in FishBase or SeaLifeBase.
-   `rfishbase 3.0` side-stepped the API by making queries which
    directly downloaded compressed csv tables from a static web host.
    This substantially improved performance a reliability, particularly
    for large queries. The release largely remained backwards compatible
    with 2.0, and added more tables.
-   `rfishbase 4.0` extends the static model and interface. Static
    tables are distributed in parquet and accessed through a
    provenance-based identifier. While old functions are retained, a new
    interface is introduced to provide easy access to all fishbase
    tables.

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

    # A tibble: 155,792 × 18
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
    # … with 155,782 more rows, and 11 more variables: Abundance <chr>,
    #   LifeStage <chr>, Remarks <chr>, Entered <int>, Dateentered <dttm>,
    #   Modified <int>, Datemodified <dttm>, Expert <int>, Datechecked <dttm>,
    #   WebURL <chr>, TS <dttm>

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

## SeaLifeBase

SeaLifeBase.org is maintained by the same organization and largely
parallels the database structure of Fishbase. As such, almost all
`rfishbase` functions can instead be instructed to address the

``` r
fb_tbl("species", "sealifebase")
```

    # A tibble: 97,220 × 109
       SpecCode Genus  Species Author  SpeciesRefNo FBname FamCode Subfamily GenCode
          <int> <chr>  <chr>   <chr>          <int> <chr>    <int> <chr>       <int>
     1    32307 Aapto… americ… (Pilsb…           19 <NA>       815 <NA>        27838
     2    32306 Aapto… brinto… Newman…        81749 <NA>       815 <NA>        27838
     3    32308 Aapto… callis… (Pilsb…           19 <NA>       815 <NA>        27838
     4    32304 Aapto… leptod… Newman…           19 <NA>       815 <NA>        27838
     5    32305 Aapto… trider… Newman…           19 <NA>       815 <NA>        27838
     6    51720 Aaptos aaptos  (Schmi…           19 <NA>      2630 <NA>         9253
     7   165941 Aaptos bergma… de Lau…       108813 <NA>      2630 <NA>         9253
     8   105687 Aaptos ciliata (Wilso…         3477 <NA>      2630 <NA>         9253
     9   139407 Aaptos duchas… (Topse…        85482 <NA>      2630 <NA>         9253
    10   130070 Aaptos laxosu… (Solla…        81108 <NA>      2630 <NA>         9253
    # … with 97,210 more rows, and 100 more variables: TaxIssue <int>,
    #   Remark <chr>, PicPreferredName <chr>, PicPreferredNameM <chr>,
    #   PicPreferredNameF <chr>, PicPreferredNameJ <chr>, Source <chr>,
    #   AuthorRef <int>, SubGenCode <int>, Fresh <int>, Brack <int>,
    #   Saltwater <int>, Land <int>, BodyShapeI <chr>, DemersPelag <chr>,
    #   AnaCat <chr>, MigratRef <int>, DepthRangeShallow <int>,
    #   DepthRangeDeep <int>, DepthRangeRef <int>, DepthRangeComShallow <int>, …

## Versions and importing all tables

By default, tables are downloaded the first time they are used.
`rfishbase` defaults to download the latest available snapshot; be aware
that the most recent snapshot may be months behind the latest data on
fishbase.org. Check available releases:

``` r
available_releases()
```

    [1] "21.06"

Users can trigger a one-time download of all fishbase tables (or a list
of desired tables) using `fb_import()`. This will ensure later use of
any function can operate smoothly even when no internet connection is
available. Any table already downloaded will not be re-downloaded.
(Note: `fb_import()` also returns a remote duckdb database connection to
the tables, for users who prefer to work with the remote data objects.)

``` r
conn <- fb_import()
```

## Low-memory environments

If you have very limited RAM (e.g. &lt;= 2 GB available) it may be
helpful to use `fishbase` tables in remote form by setting
`collect = FALSE`. This allows the tables to remain on disk, while the
user is still able to use almost all `dplyr` functions (see the `dbplyr`
vignette). Once the table is appropriately subset, the user will need to
call `dplyr::collect()` to use generic non-dplyr functions, such as
plotting commmands.

``` r
fb_tbl("occurrence", collect = FALSE)
```

    # Source:   table<occurrence> [?? x 106]
    # Database: duckdb_connection
       catnum2 OccurrenceRefNo SpecCode Syncode Stockcode GenusCol       SpeciesCol 
         <int>           <int>    <int>   <int>     <int> <chr>          <chr>      
     1   34424           36653      227   22902       241 "Megalops"     "cyprinoid…
     2   95154           45880       NA      NA        NA ""             ""         
     3   97606           45880       NA      NA        NA ""             ""         
     4  100025           45880     5520   25676      5809 "Johnius"      "belangeri…
     5   98993           45880     5676   16650      5969 "Chromis"      "retrofasc…
     6   99316           45880      454   23112       468 "Drepane"      "punctata" 
     7   99676           45880     5388  145485      5647 "Gymnothorax"  "boschi"   
     8   99843           45880    16813  119925     15264 "Hemiramphus"  "balinensi…
     9  100607           45880     8288   59635      8601 "Ostracion"    "rhinorhyn…
    10  101529           45880       NA      NA        NA "Scomberoides" "toloo-par…
    # … with more rows, and 99 more variables: ColName <chr>, PicName <chr>,
    #   CatNum <chr>, URL <chr>, Station <chr>, Cruise <chr>, Gazetteer <chr>,
    #   LocalityType <chr>, WaterDepthMin <dbl>, WaterDepthMax <dbl>,
    #   AltitudeMin <int>, AltitudeMax <int>, LatitudeDeg <int>, LatitudeMin <dbl>,
    #   NorthSouth <chr>, LatitudeDec <dbl>, LongitudeDeg <int>,
    #   LongitudeMIn <dbl>, EastWest <chr>, LongitudeDec <dbl>, Accuracy <chr>,
    #   Salinity <chr>, LatitudeTo <dbl>, LongitudeTo <dbl>, LatitudeDegTo <int>, …

## Interactive RStudio pane

RStudio users can also browse all fishbase tables interactively in the
RStudio connection browser by using the function `fisbase_pane()`. Note
that this function will first download a complete set of the fishbase
tables.

## Backwards compatibility

`rfishbase` 4.0 tries to maintain as much backwards compatibility as
possible with rfishbase 3.0. Because parquet preserves native data
types, some encoded types may differ from earlier versions. As before,
these are not always the native type – e.g. fishbase encodes some
boolean (logical TRUE/FALSE) values as integer (-1, 0) or character
types. Use `as.logical()` to coerce into the appropriate type in that
case.

Toggling between fishbase and sealifebase servers using an environmental
variable, `FISHBASE_API`, is now deprecated.

Note that fishbase will store downloaded files by hash in the app
directory, given by `db_dir()`. The default location can be set by
configuring the desired path in the environmental variable,
`FISHBASE_HOME`.

------------------------------------------------------------------------

Please note that this package is released with a [Contributor Code of
Conduct](https://ropensci.org/code-of-conduct/). By contributing to this
project, you agree to abide by its terms.

[![ropensci\_footer](https://ropensci.org/public_images/github_footer.png)](https://ropensci.org)
