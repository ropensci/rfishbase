context("locations")

test_that("We can query locations", {
  needs_api()
  
  #testthat::skip("need to piggyback faorefs table first")
  
  sp <- c("Labroides bicolor",  "Labroides dimidiatus", 
          "Labroides pectoralis", "Labroides phthirophagus",
          "Labroides rubrolabiatus")
  df <- distribution(sp)
  expect_is(df, "data.frame")
  
  df <- distribution()
  expect_is(df, "data.frame")
  
  df <- countrysubref()
  expect_is(df, "data.frame")
  
  df <- c_code()
  expect_is(df, "data.frame")
  
  
  df <- country_names()
  expect_is(df, "data.frame")
  
  expect_error(occurrence())
  
})

