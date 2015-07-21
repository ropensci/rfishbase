context("common names")

test_that("test common to sci name", { 
  
  needs_api()
  species <- common_to_sci(c("Bicolor cleaner wrasse", "humphead parrotfish"), Language="English")
  expect_is(species, "character")
  expect_more_than(length(species), 1)
  
  species <- common_to_sci("trout")
  expect_is(species, "character")
  n <- length(species)
  
  species <- common_to_sci(c("trout", "Coho Salmon"))
  expect_is(species, "character")
  expect_more_than(length(species), n)
})



test_that("test sci to common names", { 
  
  needs_api()
  df <- common_names(c("Labroides bicolor",  "Bolbometopon muricatum"))
  expect_is(df, "data.frame")
})

test_that("test sci_to_common", {
   needs_api()
   x <- sci_to_common("Salmo trutta")
   expect_is(x, "character")
   expect_equal(length(x), 1)
   x <- sci_to_common("Salmo trutta", Language="English")
   expect_is(x, "character")
   x <- sci_to_common("Salmo trutta", Language="French")
   expect_is(x, "character")
   expect_equal(x, "Truite commune")
})