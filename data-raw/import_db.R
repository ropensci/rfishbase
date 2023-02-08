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

fb_parquet <- "~/cboettig/rfishbase_board/fb_parquet_2023-01/"
files <- fs::dir_ls(fb_parquet, regexp = "[.]parquet")
prov::write_prov(data_out = files, 
                 title = "Fishbase Database Snapshot: A Parquet serialization",
                 description = "Database snapshot prepared by rOpenSci courtesy of Fishbase.org",
                 license = "https://creativecommons.org/licenses/by-nc/3.0/",
                 creator = list("type" = "Organization", name = "FishBase.org"),
                 version = "23.01",
                 issued = "2023-01-01",
                 code = "data-raw/import_db.R",
                 provdb = "inst/prov/fb.prov",
                 append = TRUE,
                 schema="http://schema.org")



## PROVENANCE
files <- fs::dir_ls(slb_parquet, regexp = "[.]parquet")
prov::write_prov(data_out = files, 
                 title = "SeaLifeBase Database Snapshot: A Parquet serialization",
                 description = "Database snapshot prepared by rOpenSci courtesy of SeaLifeBase and Fishbase.org",
                 license = "https://creativecommons.org/licenses/by-nc/3.0/",
                 creator = list("type" = "Organization", name = "SeaLifeBase.org"),
                 version = "21.11",
                 issued = "2021-08-01",
                 code = "data-raw/import_db.R",
                 provdb = "inst/prov/slb.prov",
                 append = TRUE,
                 schema="http://schema.org")


parquets <- basename(files)

urls <- paste0("https://github.com/cboettig/rfishbase_board/raw/main/fb_parquet_2023-01/", parquets)
urls <- paste0("https://minio.thelio.carlboettiger.info/shared-data/fishbase/fb_parquet_2023-01/", parquets)

contentid::register(urls, registries = "https://hash-archive.carlboettiger.info")


urls <- paste0("https://minio.thelio.carlboettiger.info/shared-data/fishbase/fb_parquet_2023-01/", parquets)
contentid::register(urls, registries = "https://hash-archive.carlboettiger.info")

