context("species info")

test_that("We can extract generic information from the species table", {
  needs_api()  
  df <- species_info(c("Oreochromis niloticus", "Bolbometopon muricatum")) 
  expect_is(df, "data.frame")
})


test_that("Check some classes and values of species table", {
  
  needs_api()  
  df <- species_info(c("Oreochromis niloticus", "Bolbometopon muricatum")) 
  expect_is(df, "data.frame")
  expect_is(df[["Saltwater"]], "logical")  
  expect_is(df[["SpecCode"]], "integer")  
})


test_that("We can use SpecCodes in species_info species_list", {
  
  needs_api()  
    df <- species_info(c("Oreochromis niloticus", "Bolbometopon muricatum")) 
    expect_is(df, "data.frame")
    df2 <- species_info(c("Oreochromis niloticus", "5537")) 
    expect_is(df2, "data.frame")
    expect_identical(df, df2)
})

test_that("We can pass a species_list based on taxanomic group", {
  
  needs_api()  
  fish <- species_list(Genus = "Labroides") 
  df <- species_info(fish)
  expect_is(df, "data.frame")
  
})

## Test filters
test_that("We can filter on certain fields",{
  needs_api()  
  df <- species_info(5537, fields='Genus')
  expect_is(df, "data.frame")
  expect_equal(dim(df), c(1,1))
})

test_that("We can filter on preset fields",{
  needs_api()  
  df <- species_info(5537, fields=c(rfishbase:::id_fields, rfishbase:::habitat_fields))
  expect_is(df, "data.frame")
})
## Test wrong filters?

## Test wrong species name?

## Test wrong server?
#test_that()
