context("test_list_fields")

test_that("we can search for a field name", {
  
  needs_api()
  
  df <- list_fields("Temp")
  expect_is(df, "data.frame")
  expect_gt(dim(df)[1], 0)
  
  
  df <- list_fields()
  expect_is(df, "data.frame")
  expect_gt(dim(df)[1], 0)
  
})

test_that("we can browse docs", {
  
  df <- docs()
  expect_is(df, "data.frame")
  expect_gt(dim(df)[1], 0)
  
  df <- docs("fecundity")
  expect_is(df, "data.frame")
  expect_gt(dim(df)[1], 0)
  
})
