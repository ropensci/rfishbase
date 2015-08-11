context("docs")

test_that("we can call the docs", {
  needs_api()
  
  df <- docs()
  expect_is(df, "data.frame")
  expect_is(dplyr::filter(df, table == "diet")$description, "character")
})


