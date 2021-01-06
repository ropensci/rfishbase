context("species list")

test_that("We can pass a species_list based on taxanomic group", {
  
  needs_api()
  fish <- species_list(Genus = "Labroides") 
  expect_is(fish, "character")
  expect_gt(length(fish), 1)
  
})

test_that("Look up species by SpecCode", {
  
  needs_api()
  
  fish <- species_list(SpecCode = "5537") 
  expect_is(fish, "character")
  expect_equal(fish, "Bolbometopon muricatum")
  
})


# Tests wrt caching

# Test with alternate queries? 
