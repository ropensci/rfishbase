context("test_list_fields")

test_that("we can search for a field name", {
  needs_api()
  
  df <- list_fields("Temp")
  expect_is(df, "data.frame")
})