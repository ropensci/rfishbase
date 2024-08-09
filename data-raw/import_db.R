#library(minio)
# mc("cp thelio/shared-data/fishbase/2023-02-slbapp.sql slbapp.sql")

library(DBI)
library(dplyr)
library(RMariaDB)
library(arrow)

con <- dbConnect(RMariaDB::MariaDB(), dbname="fbapp", host="mariadb", password="password", user="root")
tables <- dbListTables(con)

fs::dir_delete("fbapp") # start clean

fs::dir_create("fbapp")
#' @importFrom glue glue
duckdb <- dbConnect(duckdb::duckdb())
for(table in tables){
  df <- dplyr::collect(dplyr::tbl(con, table)) 
  DBI::dbWriteTable(duckdb, table, df)
  DBI::dbSendQuery(duckdb, glue::glue("COPY {table} TO 'fbapp/{table}.parquet' (FORMAT 'parquet');")) 
  #arrow::write_parquet(df, paste0(table,".parquet"))
}




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


