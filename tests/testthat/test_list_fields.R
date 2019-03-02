context("test_list_fields")

test_that("we can search for a field name", {
  
  df <- list_fields("Temp")
  expect_is(df, "data.frame")
  
  
  df <- list_fields()
  expect_is(df, "data.frame")
})

test_that("we can browse docs", {
  
  df <- docs()
  expect_is(df, "data.frame")
  df <- docs("fecundity")
  expect_is(df, "data.frame")
})
