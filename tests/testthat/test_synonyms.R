# Query using a synonym:
test_that("synonyms can query by species", {
  df <- synonyms("Callyodon muricatus")
  expect_is(df, "data.frame")
  expect_equal(df$SpecCode[[1]], 5537)
})

test_that("synonyms can resolve misspellings", {
  x <- synonyms("Labroides dimidatus") # Species name misspelled
  expect_equal(species_list(SpecCode = x$SpecCode), "Labroides dimidiatus")
})
  
#' 
test_that("We can get synonyms with SpecCode", {

  df <- synonyms(5537)
  expect_is(df, "data.frame")

  code <- species_info("Bolbometopon muricatum", fields="SpecCode")[[1]]
  
  expect_equal(code, 5537)
  df <- synonyms(code)
  expect_is(df, "data.frame")
  
  
})