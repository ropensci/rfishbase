context("error checks")



test_that("Waning message and no proceed if parsing fails", {
  parsed <- "parsed is a character error message"
  expect_warning(proceed <- error_checks(parsed))
  expect_false(proceed)  
})

test_that("Waning message and no proceed if parsing is empty", {
  parsed <- list()
  expect_warning(proceed <- error_checks(parsed))
  expect_false(proceed)  
})


test_that("Waning message and no proceed if parsing discovers that API returned an error", {
  parsed <- list(error = "An error message")
  expect_warning(proceed <- error_checks(parsed))
  expect_false(proceed)  
})


test_that("Waning message and no proceed if parsing discovers that returned empty", {
  parsed <- list(count = 0)
  expect_warning(proceed <- error_checks(parsed))
  expect_false(proceed)  
})


test_that("Waning message but proceed if only partial list returned because limit was reached", {
  parsed <- list(count = 10, returned = 5)
  expect_warning(proceed <- error_checks(parsed))
  expect_true(proceed)  
})


