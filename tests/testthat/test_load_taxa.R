context("load taxa")

test_that("We can load taxa from online", {

  needs_api()
  df <- load_taxa(server = "fishbase")
  expect_is(df, "tbl")
  
  
  df <- load_taxa(server="sealifebase")
  expect_is(df, "tbl")

})
