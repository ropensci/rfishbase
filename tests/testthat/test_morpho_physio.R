

test_that("population_dynamics methods can all be called successfully", {
  
  needs_api()  
  
  df <- oxygen("Oreochromis niloticus")
  expect_is(df, "data.frame")
 
})