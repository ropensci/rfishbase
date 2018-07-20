context("load taxa")

test_that("We can load taxa from online", {

  df <- load_taxa()
  expect_is(df, "data.frame")
})
