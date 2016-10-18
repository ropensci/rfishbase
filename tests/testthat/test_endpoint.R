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

test_that("paging parameters work correctly", {
  
  di_et <- endpoint("diet")
  
  res1 <- di_et(species_list = "Scomber scombrus")
  expect_equal(NROW(res1), 200)
  
  res2 <- di_et(species_list = "Scomber scombrus", limit = 5)
  expect_equal(NROW(res2), 5)
  
  res3 <- di_et(species_list = "Scomber scombrus", limit = 5, offset = 5)
  expect_false(identical(res2, res3))
  
})
