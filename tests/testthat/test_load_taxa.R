context("load taxa")

test_that("We can load taxa", {

  needs_api()
  df <- load_taxa(server = "fishbase")
  expect_is(df, "tbl")
  
  
  df <- load_taxa(server="sealifebase", db = default_db(cache=FALSE))
  expect_is(df, "tbl")

})
