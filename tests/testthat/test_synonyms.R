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
  
#' 
test_that("We can get synonyms with SpecCode", {

  needs_api()
  
  df <- synonyms(5537)
  expect_is(df, "data.frame")

  code <- species("Bolbometopon muricatum", fields="SpecCode")[[2]]
  
  expect_equal(code, 5537)
  df <- synonyms(code)
  expect_is(df, "data.frame")
    
})


test_that("We can validate names",{

  needs_api()
  x <- validate_names("Clupea pallasii")
  expect_is(x, "character")
  expect_identical(x, "Clupea pallasii pallasii")
})


