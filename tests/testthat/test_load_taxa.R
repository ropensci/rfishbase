context("load taxa")

test_that("We can load taxa from the package database", {

  df <- load_taxa()
  expect_is(df, "data.frame")
})

test_that("We can refresh the taxa list and use it in future calls", {
  
  if(TRUE) skip("skip full join, too demanding on server")

  needs_api()  
  df <- load_taxa(update = TRUE, cache = TRUE)
  expect_is(df, "data.frame")

})

