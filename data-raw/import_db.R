#remotes::install_github("cboettig/arkdb")
library(readr)
options(scipen=999) # mysql doesn't understand sci notation
library(dplyr)
library(arkdb)
src <- src_mysql("fbapp", "mariadb", password = "password")
tables <- DBI::dbListTables(src$con)
good_tables <- tables[tables != "keys"]

arkdb::ark(src, fs::dir_create("fb"), lines = 100000L, tables = good_tables)

## Check we aren't losing stuff
tbl(src, "comnames") %>% summarise(n())
readr::read_tsv("fb/comnames.tsv.bz2") %>% summarise(n())

tables <- readLines("data-raw/rfishbase_tables.txt")
local <- paste0("fb/", tables, ".tsv.bz2")
cache <- fs::dir_ls("fb", type = "file")
files <- local[local %in% cache]

lapply(cache, piggyback::pb_upload, 
       repo = "ropensci/rfishbase", 
       tag = "data", overwrite = TRUE)


#local[!(local %in% cache)]
