context("db_create")

test_that("db_create", {
  
  tbl = "brains"
  server = "rfishbase"
  version = "19.04"
  addr <- remote_url(tbl, server, version)
  local_tbl <- paste0(file.path(tempdir(), tbl_name(tbl, server, version)), ".tsv.bz2")
  curl::curl_download(addr, dest =  local_tbl)

  
  test <- readr::read_tsv(local_tbl)
  db = default_db("testdir")
  
  arkdb::unark(local_tbl,
               db, 
               arkdb::streamable_readr_tsv(), 
               overwrite = TRUE,
               col_types = readr::cols(.default = "c")
  )
})

test_that("we can create the local db for a specified tbl", {
  
  needs_api()
  db = default_db(tempdir())
  db_create("brains", db = db)
  eco <- fb_tbl("ecology", db = db)
  expect_is(eco, "tbl")
})