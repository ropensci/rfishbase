context("load taxa")

test_that("We can load taxa from online", {

  needs_api()
  df <- load_taxa()
  expect_is(df, "data.frame")
  expect_gt(dim(df)[1], 0)
  
  df <- load_taxa(server="sealifebase")
  expect_is(df, "data.frame")
  expect_gt(dim(df)[1], 0)
  
})
