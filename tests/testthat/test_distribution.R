context("locations")

test_that("We can query locations", {
  needs_api()
  
  #testthat::skip("need to piggyback faorefs table first")
  
  sp <- c("Labroides bicolor",  "Labroides dimidiatus", 
          "Labroides pectoralis", "Labroides phthirophagus",
          "Labroides rubrolabiatus")
  df <- faoareas(sp)
  expect_is(df, "data.frame")
  
  df <- faoareas()
  expect_is(df, "data.frame")
  
  ## currently these are remote tables
  ## collecting them may create issues since
  ## country_names() is used internally
  df <- countrysubref()
  expect_is(df, "tbl")
  
  df <- c_code()
  expect_is(df, "tbl")
  
  
  df <- country_names()
  expect_is(df, "tbl")
  

})

