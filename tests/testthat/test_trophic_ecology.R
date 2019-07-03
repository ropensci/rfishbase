context("trophic_ecology")
test_that("we can call the trpohic ecology information  table", {
  needs_api()

  df <- diet_items("Oreochromis niloticus")
  expect_is(df, "tbl")
    
  df <- fooditems("Oreochromis niloticus")
  expect_is(df, "tbl")
})

