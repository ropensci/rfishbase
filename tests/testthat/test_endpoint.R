test_that("we can create endpoints with closures", {
  
  example <- endpoint("species")
  expect_is(example, "function")
})

test_that("Custom queries give desired result", {
  
  needs_api()
  country <- endpoint("country")
  df <- country()
  expect_is(df, "tbl")

  df <- country("Oreochromis niloticus")
  expect_is(df, "tbl")

  references()
  rr <- references(codes = c(1, 4))
  expect_is(rr, "tbl")
  expect_equal(nrow(rr), 2)
  
  df <- species_names(2)
  expect_is(df, "tbl")

})

