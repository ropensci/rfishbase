library(RMariaDB)
library(RMySQL)
library(DBI)
library(dplyr)
library(readr)


con <- DBI::dbConnect(RMariaDB::MariaDB(), "fbapp", user="root", host="mariadb", password = "password")
tables <- DBI::dbListTables(con)

## Fallback on RMySQL -- does not handle dates or some long text columns as well, but does not fail hard
con2 <- DBI::dbConnect(RMySQL::MySQL(), "fbapp", user="root", host="mariadb", password = "password")
fs::dir_create("fb")
fs::dir_create("parquet/fb", recurse = TRUE)

for(table in tables){
        message(table)
        df <- tryCatch({
                dplyr::collect(dplyr::tbl(con, table))
        }, error = function(e) {
                dplyr::collect(dplyr::tbl(con2, table))
        },
        finally=data.frame())
        df <- df %>% mutate(across(where(is.list), as.character))
        path <- file.path("fb", paste0(table, ".tsv.bz2"))
        if(nrow(df) > 0){
                readr::write_tsv(df, path)
                arrow::write_parquet(df, file.path("parquet", path))
        }
}





con <- DBI::dbConnect(RMariaDB::MariaDB(), "slbapp", user="root", host="mariadb", password = "password")
tables <- DBI::dbListTables(con)

## Fallback on RMySQL -- does not handle dates or some long text columns as well, but does not fail hard
con2 <- DBI::dbConnect(RMySQL::MySQL(), "slbapp", user="root", host="mariadb", password = "password")
fs::dir_create("parquet/slb", recurse = TRUE)
fs::dir_create("slb")
for(table in tables){
        message(table)
        df <- tryCatch({
                dplyr::collect(dplyr::tbl(con, table))
        }, error = function(e) {
                dplyr::collect(dplyr::tbl(con2, table))
        },
        finally=data.frame())
        df <- df %>% mutate(across(where(is.list), as.character))
        path <- file.path("slb", paste0(table, ".tsv.bz2"))
        if(nrow(df) > 0){
                readr::write_tsv(df, path)
                #arrow::write_parquet(df, file.path("parquet", path))
        }
        gc()
}



## Check we aren't losing stuff
#tbl(src, "comnames") %>% summarise(n())
#readr::read_tsv("fb/comnames.tsv.bz2") %>% summarise(n())

#tables <- readLines("data-raw/rfishbase_tables.txt")

cache <- fs::dir_ls("fb", type = "file")
piggyback::pb_upload(cache,
                     repo = "ropensci/rfishbase", 
                     tag = "fb-21.04", overwrite = TRUE)

# local <- paste0("fb/", tables, ".tsv.bz2")
# files <- local[local %in% cache]





cache <- fs::dir_ls("slb", type = "file")

piggyback::pb_upload(cache,
       repo = "ropensci/rfishbase", 
       tag = "slb-21.04", overwrite = TRUE)

