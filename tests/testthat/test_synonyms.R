context("synonyms")

# Query using a synonym:
test_that("synonyms can query by species", {
  
  needs_api()
  
  df <- synonyms("Callyodon muricatus")
  expect_is(df, "data.frame")
  expect_equal(as.numeric(df$SpecCode[[1]]), 5537)
})

test_that("synonyms can resolve misspellings", {
  
  needs_api()
  
  x <- synonyms("Labroides dimidatus") # Species name misspelled
  expect_equal(x %>% pull(Species), "Labroides dimidiatus")
})
  

test_that("synonyms can resolve in sealifebase", {
  
  needs_api()
  
  x <- synonyms(server="sealifebase") 
  expect_is(x, "tbl")
})

test_that("We can validate names",{

  needs_api()
  x <- validate_names("Clupea pallasii")
  expect_is(x, "character")
  expect_identical(x, "Clupea pallasii")
  # expect_identical(x, "Clupea pallasii pallasii")

  x <- validate_names(c(rep("Agonomalus jordani", 2), "wrong"))
  expect_identical(x, c(rep("Agonomalus jordani", 2), NA))
})


