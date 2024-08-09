
fb.prov <- "inst/prov/fb.prov"

prov::write_prov(
  data_out =  paste0("https://github.com/cboettig/rfishbase_board/raw/main/fb_parquet_2023-05/", 
                     basename(fs::dir_ls("../rfishbase_board/fb_parquet_2023-07/"))),
  title = "FishBase Snapshots v24.07",
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

