test_that("we can create endpoints with closures", {
  
  example <- endpoint("species")
  expect_is(example, "function")
})