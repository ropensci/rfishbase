

test_that("population_dynamics methods can all be called successfully", {
  
  needs_api()  
  
  df <- popchar("Oreochromis niloticus")
  expect_is(df, "data.frame")
  
  df <- popgrowth("Oreochromis niloticus", fields=
                    "TLinfinity")
  expect_is(df, "data.frame")
  
  df <- length_length("Oreochromis niloticus")
  expect_is(df, "data.frame")
  
  df <- length_freq("Oreochromis niloticus")
  expect_is(df, "data.frame")
  
  df <- length_weight("Oreochromis niloticus")
  expect_is(df, "data.frame")
  
})