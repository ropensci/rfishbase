context("trophic_ecology")
test_that("we can call the trophic ecology information  table", {
  needs_api()

  df <- diet_items() # not a species-oriented table
  expect_is(df, "tbl")
    
  df <- fooditems("Oreochromis niloticus")
  expect_is(df, "tbl")
})

