testthat::context("sealifebase")

testthat::test_that("We get taxa table from sealifebase", {
  needs_api()
  crabs <- common_to_sci("king crab", server = "https://fishbase.ropensci.org/sealifebase")
  testthat::expect_true("Limulus polyphemus" %in% crabs)
})