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

fb.prov <- "inst/prov/fb.prov"

prov::write_prov(
  data_out =  paste0("https://github.com/cboettig/rfishbase_board/raw/main/fb_parquet_2023-05/", 
                     basename(fs::dir_ls("../rfishbase_board/fb_parquet_2023-05/"))),
  title = "FishBase Snapshots v23.05",
  description = "Parquet formatted Snapshots of FishBase Tables, distributed by rOpenSci",
  license = "https://creativecommons.org/licenses/by-nc/3.0/",
  creator = list("type" = "Organization", name = "FishBase.org", "@id" = "https://fishbase.org"),
  version = "23.05",
  issued = "2023-02-01",
  prov=fb.prov,
  schema="http://schema.org",
  append=TRUE)

fs::file_copy(fb.prov, "fb_prov.json")
fs::file_copy("fb_prov.json", fb.prov, overwrite = TRUE)

jsonld::jsonld_frame(fb.prov,
'{
  "@context": "http://schema.org/",
  "@type": "Dataset"
}') |> 
  readr::write_lines(fb.prov)





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


slb.prov <- "inst/prov/slb.prov"

prov::write_prov(
  data_out =  paste0("https://github.com/cboettig/rfishbase_board/raw/main/slb_parquet_2023-05/", 
                     basename(fs::dir_ls("../rfishbase_board/slb_parquet_2023-05/"))),
  title = "SeaLifeBase Snapshots v23.05",
  description = "Parquet formatted Snapshots of FishBase Tables, distributed by rOpenSci",
  license = "https://creativecommons.org/licenses/by-nc/3.0/",
  creator = list("type" = "Organization", name = "FishBase.org", "@id" = "https://fishbase.org"),
  version = "23.05",
  issued = "2023-02-01",
  prov=slb.prov,
  schema="http://schema.org",
  append=TRUE)

fs::file_copy(slb.prov, "slb_prov.json")
#fs::file_copy("slb_prov.json", slb.prov, overwrite = TRUE)

jsonld::jsonld_frame(slb.prov,
                     '{
  "@context": "http://schema.org/",
  "@type": "Dataset"
}') |> 
  readr::write_lines(slb.prov)



#mc("cp -r /home/cboettig/cboettig/rfishbase_board/fb_parquet_2023-01 thelio/shared-data/fishbase/")
#mc("cp -r slb_parquet_2023-01 thelio/shared-data/fishbase/")


