
# rfishbase <img src="man/figures/logo.svg" align="right" alt="" width="120" />

<!-- badges: start -->

[![R-CMD-check](https://github.com/ropensci/rfishbase/workflows/R-CMD-check/badge.svg)](https://github.com/ropensci/rfishbase/actions)
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

    # A tibble: 157,870 × 18
       autoctr E_CODE Ecosy…¹ Specc…² Stock…³ Status Curre…⁴ Abund…⁵ LifeS…⁶ Remarks
         <int>  <int>   <int>   <int>   <int> <chr>  <chr>   <chr>   <chr>   <chr>  
     1       1      1   50628     549     565 native Present <NA>    adults  <NA>   
     2       2      1     189     552     568 native Present <NA>    adults  <NA>   
     3       3      1     189     554     570 native Present <NA>    adults  <NA>   
     4       4      1   79732     873     889 native Present <NA>    adults  <NA>   
     5       5      1    5217     948     964 native Present <NA>    adults  <NA>   
     6       7      1   39852     956     972 native Present <NA>    adults  <NA>   
     7       8      1   39852     957     973 native Present <NA>    adults  <NA>   
     8       9      1   39852     958     974 native Present <NA>    adults  <NA>   
     9      10      1     188    1526    1719 native Present <NA>    adults  <NA>   
    10      11      1     188    1626    1819 native Present <NA>    adults  <NA>   
    # … with 157,860 more rows, 8 more variables: Entered <int>,
    #   Dateentered <dttm>, Modified <int>, Datemodified <dttm>, Expert <int>,
    #   Datechecked <dttm>, WebURL <chr>, TS <dttm>, and abbreviated variable names
    #   ¹​EcosystemRefno, ²​Speccode, ³​Stockcode, ⁴​CurrentPresence, ⁵​Abundance,
    #   ⁶​LifeStage

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

    # A tibble: 103,169 × 109
       SpecCode Genus  Species Author Speci…¹ FBname FamCode Subfa…² GenCode TaxIs…³
          <int> <chr>  <chr>   <chr>    <int> <chr>    <int> <chr>     <int>   <int>
     1    10217 Abyss… cidaris Poore…    3113 <NA>       512 <NA>       9280       0
     2    10218 Abyss… panope  Poore…    3113 <NA>       512 <NA>       9280       0
     3    90399 Abyss… averin… Kussa…    3113 <NA>       502 <NA>      17490       0
     4    52610 Abyss… millari Monni…    2585 <NA>       978 <NA>       9281       0
     5    52611 Abyss… wyvill… Herdm…    2892 <NA>       978 <NA>       9281       0
     6   138684 Abyss… planus  (Slad…   81020 <NA>      1615 <NA>      24229       0
     7    90400 Abyss… acutil… Doti …    3113 <NA>       587 <NA>       9282       0
     8    10219 Abyss… argent… Menzi…    3113 <NA>       587 <NA>       9282       0
     9    10220 Abyss… bathya… Just,…    3113 <NA>       587 <NA>       9282       0
    10    10221 Abyss… dentif… Menzi…    3113 <NA>       587 <NA>       9282       0
    # … with 103,159 more rows, 99 more variables: Remark <chr>,
    #   PicPreferredName <chr>, PicPreferredNameM <chr>, PicPreferredNameF <chr>,
    #   PicPreferredNameJ <chr>, Source <chr>, AuthorRef <int>, SubGenCode <int>,
    #   Fresh <int>, Brack <int>, Saltwater <int>, Land <int>, BodyShapeI <chr>,
    #   DemersPelag <chr>, AnaCat <chr>, MigratRef <int>, DepthRangeShallow <int>,
    #   DepthRangeDeep <int>, DepthRangeRef <int>, DepthRangeComShallow <int>,
    #   DepthRangeComDeep <int>, DepthComRef <int>, LongevityWild <dbl>, …

## Versions and importing all tables

By default, tables are downloaded the first time they are used.
`rfishbase` defaults to download the latest available snapshot; be aware
that the most recent snapshot may be months behind the latest data on
fishbase.org. Check available releases:

``` r
available_releases()
```

    [1] "23.01" "21.06" "19.04"

## Low-memory environments

If you have very limited RAM (e.g. \<= 1 GB available) it may be helpful
to use `fishbase` tables in remote form by setting `collect = FALSE`.
This allows the tables to remain on disk, while the user is still able
to use almost all `dplyr` functions (see the `dbplyr` vignette). Once
the table is appropriately subset, the user will need to call
`dplyr::collect()` to use generic non-dplyr functions, such as plotting
commands.

``` r
fb_tbl("occurrence")
```

    # A tibble: 1,097,303 × 106
       catnum2 OccurrenceR…¹ SpecC…² Syncode Stock…³ Genus…⁴ Speci…⁵ ColName PicName
         <int>         <int>   <int>   <int>   <int> <chr>   <chr>   <chr>   <chr>  
     1   34424         36653     227   22902     241 "Megal… "cypri… "Megal… ""     
     2   95154         45880      NA      NA      NA ""      ""      ""      ""     
     3   97606         45880      NA      NA      NA ""      ""      ""      ""     
     4  100025         45880    5520   25676    5809 "Johni… "belan… ""      ""     
     5   98993         45880    5676   16650    5969 "Chrom… "retro… ""      ""     
     6   99316         45880     454   23112     468 "Drepa… "punct… ""      ""     
     7   99676         45880    5388  145485    5647 "Gymno… "bosch… ""      ""     
     8   99843         45880   16813  119925   15264 "Hemir… "balin… ""      ""     
     9  100607         45880    8288   59635    8601 "Ostra… "rhino… ""      ""     
    10  101529         45880      NA      NA      NA "Scomb… "toloo… ""      ""     
    # … with 1,097,293 more rows, 97 more variables: CatNum <chr>, URL <chr>,
    #   Station <chr>, Cruise <chr>, Gazetteer <chr>, LocalityType <chr>,
    #   WaterDepthMin <dbl>, WaterDepthMax <dbl>, AltitudeMin <int>,
    #   AltitudeMax <int>, LatitudeDeg <int>, LatitudeMin <dbl>, NorthSouth <chr>,
    #   LatitudeDec <dbl>, LongitudeDeg <int>, LongitudeMIn <dbl>, EastWest <chr>,
    #   LongitudeDec <dbl>, Accuracy <chr>, Salinity <chr>, LatitudeTo <dbl>,
    #   LongitudeTo <dbl>, LatitudeDegTo <int>, LatitudeMinTo <dbl>, …

## Local copy

Set the option “rfishbase_local_db” = TRUE to create a local copy,
otherwise will use a remote copy. Local copy will get better performance
after initial import, but may experience conflicts when `duckdb` is
upgraded or when multiple sessions attempt to access the directory.
Remove the default storage directory (given by `db_dir()`) after
upgrading duckdb if using a local copy.

``` r
options("rfishbase_local_db" = TRUE)
db_disconnect() # close previous remote connection

conn <- fb_conn()
conn
```

    <duckdb_connection 5fa20 driver=<duckdb_driver 543a0 dbdir='/home/cboettig/.local/share/R/rfishbase/fishbase_23.01' read_only=FALSE bigint=numeric>>

Users can trigger a one-time download of all fishbase tables (or a list
of desired tables) using `fb_import()`. This will ensure later use of
any function can operate smoothly even when no internet connection is
available. Any table already downloaded will not be re-downloaded.
(Note: `fb_import()` also returns a remote duckdb database connection to
the tables, for users who prefer to work with the remote data objects.)

``` r
fb_import()
```

    <duckdb_connection 5fa20 driver=<duckdb_driver 543a0 dbdir='/home/cboettig/.local/share/R/rfishbase/fishbase_23.01' read_only=FALSE bigint=numeric>>

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

[![ropensci_footer](https://ropensci.org/public_images/github_footer.png)](https://ropensci.org)
