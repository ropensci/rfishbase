context("ecology")
test_that("we can call the ecology table", {
  needs_api()
  
  df <- ecology("Oreochromis niloticus")
  expect_is(df, "data.frame")
})

#' 
#' ## trophic levels and standard errors for a list of species

test_that("We can query trophic level fields only", {
  needs_api()
  
  df <- ecology(c("Oreochromis niloticus", "Salmo trutta"),
                fields=c("SpecCode", "FoodTroph", "FoodSeTroph", "DietTroph", "DietSeTroph"))
  expect_is(df, "data.frame")
  
  expect_equal(dim(df)[2], 7)
})
