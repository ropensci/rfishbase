library(RMariaDB)
library(RMySQL)
library(DBI)
library(dplyr)
library(readr)


fb <- fs::dir_create("data-raw/fb_2021-06")
fb_parquet <- fs::dir_create("parquet/fb_parquet_2021-06")
slb <- fs::dir_create("data-raw/slb_2021-08")
slb_parquet <- fs::dir_create("parquet/slb_parquet_2021-08")


con <- DBI::dbConnect(RMariaDB::MariaDB(), "fbapp",
                      user="root", host="mariadb", password = "password")
tables <- DBI::dbListTables(con)
species <- dbReadTable(con, "species")

## Fallback on RMySQL -- does not handle dates or some long text columns as well, but does not fail hard
#con2 <- DBI::dbConnect(RMySQL::MySQL(), "fbapp", user="root", host="mariadb", password = "password")

for(table in tables){
        message(table)
        df <- tryCatch({
                dplyr::collect(dplyr::tbl(con, table))
        }, error = function(e) {
                stop(e)
                #dplyr::collect(dplyr::tbl(con2, table))
        },
        finally=data.frame())
        df <- df %>% mutate(across(where(is.list), as.character))
        path <- file.path(fb, paste0(table, ".tsv.gz"))
        if(nrow(df) > 0){
                readr::write_tsv(df, path, quote="none")
                arrow::write_parquet(df, file.path(fb_parquet, 
                                                   paste0(table, ".parquet")))
        }
}





con <- DBI::dbConnect(RMariaDB::MariaDB(), "slbapp", user="root", host="mariadb", password = "password")
tables <- DBI::dbListTables(con) %>% sort()

## Fallback on RMySQL -- does not handle dates or some long text columns as well, but does not fail hard
con2 <- DBI::dbConnect(RMySQL::MySQL(), "slbapp", user="root", host="mariadb", password = "password")




safe_tables <- tables[!(tables %in% c("ecosystem", "ecosystemcountry"))]

# Note: internal error: row 378050 field 9 truncated
ecosystem <- DBI::dbReadTable(con2, "ecosystem") %>% as_tibble()

for(table in safe_tables){
        message(table)
        df <- tryCatch({
                DBI::dbReadTable(con, table)
        }, error = function(e) {
                # warning(e)
                DBI::dbReadTable(con2, table)
        },
        finally=data.frame())
        df <- df %>% mutate(across(where(is.list), as.character))
        path <- 
        if(nrow(df) > 0){
                readr::write_tsv(df, path, quote="none")
                arrow::write_parquet(df, file.path(slb_parquet, 
                                                   paste0(table, ".parquet")))
        }
        gc()
}

## These are a bit unstable in readr...
table<- "ecosystemcountry" # "ecosystem" 
df <- DBI::dbReadTable(con2, table)
readr::write_tsv(df, file.path(slb, paste0(table,".tsv.gz")), quote="none")
arrow::write_parquet(df, file.path(slb_parquet, paste0(table, ".parquet")))



## PROVENANCE
files <- fs::dir_ls(fb_parquet, regexp = "[.]parquet")
prov::write_prov(data_out = files, 
                 title = "Fishbase Database Snapshot: A Parquet serialization",
                 description = "Database snapshot prepared by rOpenSci courtesy of Fishbase.org",
                 license = "https://creativecommons.org/licenses/by-nc/3.0/",
                 creator = list("type" = "Organization", name = "FishBase.org"),
                 version = "21.06",
                 issued = "2021-06-01",
                 code = "data-raw/import_db.R",
                 provdb = "parquet/fb-2021-06.prov",
                 append = FALSE,
                 schema="http://schema.org")



## PROVENANCE
files <- fs::dir_ls(slb_parquet, regexp = "[.]parquet")
prov::write_prov(data_out = files, 
                 title = "SeaLifeBase Database Snapshot: A Parquet serialization",
                 description = "Database snapshot prepared by rOpenSci courtesy of SeaLifeBase and Fishbase.org",
                 license = "https://creativecommons.org/licenses/by-nc/3.0/",
                 creator = list("type" = "Organization", name = "SeaLifeBase.org"),
                 version = "21.08",
                 issued = "2021-08-01",
                 code = "data-raw/import_db.R",
                 provdb = "parquet/slb-2021-08.prov",
                 append = FALSE,
                 schema="http://schema.org")



### CSV uploads

## Check we aren't losing stuff
#tbl(src, "comnames") %>% summarise(n())
#readr::read_tsv("fb/comnames.tsv.bz2") %>% summarise(n())

#tables <- readLines("data-raw/rfishbase_tables.txt")

#cache <- fs::dir_ls(fb, type = "file")
#piggyback::pb_upload(cache,
#                     repo = "ropensci/rfishbase", 
#                     tag = "fb-21.06", overwrite = TRUE)

# local <- paste0("fb/", tables, ".tsv.bz2")
# files <- local[local %in% cache]

#cache <- fs::dir_ls(slb, type = "file")
#piggyback::pb_upload(cache,
#                     repo = "ropensci/rfishbase", 
#                     tag = "slb-21.08", overwrite = TRUE)

