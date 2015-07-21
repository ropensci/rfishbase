context("species")

test_that("We can extract generic information from the species table", {
  needs_api()  
  df <- species(c("Oreochromis niloticus", "Bolbometopon muricatum")) 
  expect_is(df, "data.frame")
})


test_that("Check some classes and values of species table", {
  
  needs_api()  
  df <- species(c("Oreochromis niloticus", "Bolbometopon muricatum")) 
  expect_is(df, "data.frame")
  #expect_is(df[["Saltwater"]], "logical")   ## FIXME Class conversion not handled now do to api changes
  expect_is(df[["SpecCode"]], "integer")  
})


test_that("We can pass a species_list based on taxanomic group", {
  
  needs_api()  
  fish <- species_list(Genus = "Labroides") 
  df <- species(fish)
  expect_is(df, "data.frame")
  
})

## Test filters
test_that("We can filter on certain fields",{
  needs_api()  
  df <- species(c("Oreochromis niloticus", "Bolbometopon muricatum"), fields='Genus')
  expect_is(df, "data.frame")
  expect_equal(dim(df), c(2,3))
})

test_that("We can filter on preset fields",{
  needs_api()  
  df <- species(c("Oreochromis niloticus", "Bolbometopon muricatum"), fields=c(species_fields$id, species_fields$habitat))
  expect_is(df, "data.frame")
})
## Test wrong filters?

## Test wrong species name?

## Test wrong server?
#test_that()
