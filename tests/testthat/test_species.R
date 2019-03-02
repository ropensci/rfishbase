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
 # expect_is(df[["SpecCode"]], "numeric")  #sometimes integer
})


test_that("We can pass a species_list based on taxanomic group", {
  
  needs_api()  
  fish <- species_list(Genus = "Labroides") 
  df <- species(fish)
  expect_is(df, "data.frame")
  expect_gt(dim(df)[1], 0)
  
  
})

test_that("We can pass a species_list based on taxanomic group", {
  
  needs_api()  
  fish <- species_list(Genus = "Labroides") 
  df <- species(fish)
  expect_is(df, "data.frame")
  expect_gt(dim(df)[1], 0)
  
  
})

## Test filters
test_that("We can filter on certain fields",{
  needs_api()  
  df <- species(c("Oreochromis niloticus", "Bolbometopon muricatum"), 
                fields=c('SpecCode', 'Species'))
  expect_is(df, "data.frame")
  expect_gt(dim(df)[1], 0)
  
  df <- load_species_meta()
  
})

