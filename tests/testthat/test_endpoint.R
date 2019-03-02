test_that("we can create endpoints with closures", {
  
  example <- endpoint("species")
  expect_is(example, "function")
})

test_that("Custom queries give desired result", {
  
  needs_api()
  country <- endpoint("country")
  df <- country()
  expect_is(df, "data.frame")
  expect_gt(dim(df)[1], 0)
  
  df <- country("Oreochromis niloticus")
  expect_is(df, "data.frame")
  expect_gt(dim(df)[1], 0)
  
  references()
  
  df <- species_names(2)
  expect_is(df, "data.frame")
  expect_gt(dim(df)[1], 0)
  
})

