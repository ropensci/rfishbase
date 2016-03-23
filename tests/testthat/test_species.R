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

test_that("Fully unmatched species names throw error",{
  needs_api()  
  expect_error(species(c("foo", "bar")))
})

test_that("Partial species match gives warning for missing matches",{
  needs_api()  
  expect_warning(species(c("Oreochromis niloticus", "Bolbometopon muricatum","foo", "bar")), 'supplied species names did not match any species in the database')
})

test_that("Partial species match gives warning for missing matches",{
  needs_api()  
  expect_warning(species(c("Oreochromis niloticus", "Bolbometopon muricatum","foo", "bar")), 'supplied species names did not match any species in the database')
})

test_that("Duplicate species names in species_list returns unique match",{
  needs_api()  
  df_s <- species("Oreochromis niloticus")
  df_d <- species(c("Oreochromis niloticus", "Oreochromis niloticus"))
  df_dm <- species(c("Oreochromis niloticus", "Oreochromis niloticus", "foo"))
  expect_equal(nrow(df_s), nrow(df_d))
  expect_equal(nrow(df_s), nrow(df_dm))
})

test_that("Sealifebase species are matched",{
  needs_api()  
  df_s <- species("Homarus americanus", 
                  server = "https://fishbase.ropensci.org/sealifebase")
  df_d <- species(c("Homarus americanus", "Homarus americanus"), 
                  server = "https://fishbase.ropensci.org/sealifebase")
  df_dm <- species(c("Homarus americanus", "Homarus americanus", "foo"),
                  server = "https://fishbase.ropensci.org/sealifebase")
  
  expect_equal(nrow(df_s), nrow(df_d))
  expect_equal(nrow(df_s), nrow(df_dm))
})

test_that("no species list returns table up to limit",{
  needs_api()  
  df_fb <- species(limit=6000)
  df_slb <- species(limit=6000, server = "https://fishbase.ropensci.org/sealifebase")
  
  expect_equal(nrow(df_fb), 6000)
  expect_equal(nrow(df_slb), 6000)
})

## Test wrong server?
#test_that()
