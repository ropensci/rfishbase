context("synonyms")

# Query using a synonym:
test_that("synonyms can query by species", {
  
  needs_api()
  
  df <- synonyms("Callyodon muricatus")
  expect_is(df, "data.frame")
  expect_equal(df$SpecCode[[1]], 5537)
})

test_that("synonyms can resolve misspellings", {
  
  needs_api()
  
  x <- synonyms("Labroides dimidatus") # Species name misspelled
  expect_equal(species_list(SpecCode = x$SpecCode), "Labroides dimidiatus")
})
  


test_that("We can validate names",{

  needs_api()
  x <- validate_names("Clupea pallasii")
  expect_is(x, "character")
  expect_identical(x, "Clupea pallasii pallasii")
})


