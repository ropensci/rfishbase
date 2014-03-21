context("species")

test_that("We can parse queries with fb2_species_table", {
  dat <- fb2_species_table("acanthodes")
  expect_equal(dat$Fresh, "0")

  response  <- fb2_species_table("acanthodes", debug = TRUE)
  expect_equals(response$status, 200)

})

