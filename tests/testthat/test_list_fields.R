context("test_list_fields")

test_that("we can search for a field name", {
  needs_api()
  
  if(TRUE) skip("skip test_list_fields")
  
  
  df <- list_fields("Temp")
  expect_is(df, "data.frame")
})