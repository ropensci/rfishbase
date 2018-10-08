library(readr)
library(dplyr)
library(arkdb)

src <- src_mysql("fbapp", "mysql", password = "root")
tables <- DBI::dbListTables(src$con)
good_tables <- tables[tables != "keys"]
arkdb::ark(src, fs::dir_create("fb"), lines = 100000L, 
           tables = good_tables, overwrite = FALSE)

## Check we aren't losing stuff
#tbl(src, "comnames") %>% summarise(n())
#readr::read_tsv("fb/comnames.tsv.bz2") %>% summarise(n())

#tables <- readLines("data-raw/rfishbase_tables.txt")

cache <- fs::dir_ls("fb", type = "file")

# local <- paste0("fb/", tables, ".tsv.bz2")
# files <- local[local %in% cache]

piggyback::pb_upload(cache,
       repo = "ropensci/rfishbase", 
       tag = "fb-18.10", 
       overwrite = TRUE)





src <- src_mysql("slbapp", "sealifebase", password = "root")
tables <- DBI::dbListTables(src$con)
## some listed tables do not actually exist:
good_tables <- tables[!(tables %in% c("keys", 
                                      "countref.old", 
                                      "country.orig", 
                                      "refrens.orig", 
                                      "stocks.orig"))]
arkdb::ark(src, fs::dir_create("slb"), lines = 100000L, tables = good_tables)

cache <- fs::dir_ls("slb", type = "file")

piggyback::pb_upload(cache,
       repo = "ropensci/rfishbase", 
       tag = "slb-18.10", overwrite = TRUE)

