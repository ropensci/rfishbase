#library(minio)
# mc("cp thelio/shared-data/fishbase/2023-02-slbapp.sql slbapp.sql")

library(DBI)
library(dplyr)
library(RMariaDB)
library(arrow)

con <- dbConnect(RMariaDB::MariaDB(), dbname="fbapp", host="mariadb", password="password", user="root")
tables <- dbListTables(con)

duckdb <- dbConnect(duckdb::duckdb())
for(table in tables){
  df <- dplyr::collect(dplyr::tbl(con, table)) 
  DBI::dbWriteTable(duckdb, table, df)
  DBI::dbSendQuery(duckdb, glue::glue("COPY {table} TO 'fbapp/{table}.parquet' (FORMAT 'parquet');")) 
  #arrow::write_parquet(df, paste0(table,".parquet"))
}

urls <- paste0("https://github.com/cboettig/rfishbase_board/raw/main/fb_parquet_2023-01/", tables, ".parquet")

prov::write_prov(data_out = urls, 
                 title = "Fishbase Database Snapshot: A Parquet serialization",
                 description = "Database snapshot prepared by rOpenSci courtesy of Fishbase.org",
                 license = "https://creativecommons.org/licenses/by-nc/3.0/",
                 creator = list("type" = "Organization", name = "FishBase.org"),
                 version = "23.01",
                 issued = "2023-01-01",
                 provdb = "inst/prov/fb.prov",
                 append = TRUE,
                 schema="http://schema.org")




library(RMySQL) # mariadb can't handle embedded nulls
#con <- dbConnect(RMariaDB::MariaDB(), dbname="slbapp", host="mariadb", password="password", user="root")
con <- dbConnect(RMySQL::MySQL(), dbname="slbapp", host="mariadb", password="password", user="root")

tables <- dbListTables(con)
fs::dir_create("slbapp")
for(table in tables){
  df <- dplyr::collect(dplyr::tbl(con, table)) 
  dest <- file.path("slbapp", paste0(table,".parquet"))
  DBI::dbWriteTable(duckdb, table, df, overwrite=TRUE)
  DBI::dbSendQuery(duckdb, glue::glue("COPY '{table}' TO 'slbapp/{table}.parquet' (FORMAT 'parquet');")) 
}


urls <- paste0("https://github.com/cboettig/rfishbase_board/raw/main/slb_parquet_2023-01/", tables, ".parquet")



prov::write_prov(data_out = urls, 
                 title = "SeaLifeBase Database Snapshot: A Parquet serialization",
                 description = "Database snapshot prepared by rOpenSci courtesy of Fishbase.org",
                 license = "https://creativecommons.org/licenses/by-nc/3.0/",
                 creator = list("type" = "Organization", name = "FishBase.org"),
                 version = "23.01",
                 issued = "2023-01-01",
                 provdb = "inst/prov/slb.prov",
                 append = TRUE,
                 schema="http://schema.org")



#mc("cp -r /home/cboettig/cboettig/rfishbase_board/fb_parquet_2023-01 thelio/shared-data/fishbase/")
#mc("cp -r slb_parquet_2023-01 thelio/shared-data/fishbase/")


