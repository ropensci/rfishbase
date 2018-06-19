test_that("we can create endpoints with closures", {
  
  example <- endpoint("species")
  expect_is(example, "function")
})

test_that("Custom queries give desired result", {
  
  country <- endpoint("country")
  df <- country()
  expect_is(df, "data.frame")
  
  df <- country("Oreochromis niloticus")
  expect_is(df, "data.frame")
  
})

