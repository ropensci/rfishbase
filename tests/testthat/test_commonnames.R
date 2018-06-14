context("common names")

test_that("test common to sci name", { 
  
  needs_api()
  species <- common_to_sci(c("Bicolor cleaner wrasse", "humphead parrotfish"), Language="English")
  expect_is(species$Species, "character")
  expect_gt(length(species$Species), 1)
  
  species <- common_to_sci("trout")
  expect_is(species, "character")
  n <- length(species)
  
  species <- common_to_sci(c("trout", "Coho Salmon"))
  expect_is(species$Species, "character")
  expect_gt(length(species$Species), n)
})



test_that("test sci to common names", { 
  needs_api()
  df <- common_names(c("Labroides bicolor",  "Bolbometopon muricatum"))
  expect_is(df, "data.frame")
})
