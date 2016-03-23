test_that("we can create endpoints with closures", {
  
  example <- endpoint("species")
  expect_is(example, "function")
})

test_that("Custom queries give desired result", {
  
  country <- endpoint("country")
  df <- country(query = list(C_Code=440))
  expect_true(all(df$C_Code == '440'))
  
  df <- country("Oreochromis niloticus", query = list(C_Code='050'))
  expect_true(all(df$C_Code == '050'))
  
})