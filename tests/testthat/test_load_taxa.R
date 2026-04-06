context("load taxa")

test_that("fishbase loads", {
  needs_api()
  df <- load_taxa(server = "fishbase")
  expect_is(df, "tbl")
})

test_that("sealifebase loads with expected structure", {
  needs_api()
  df <- load_taxa(server = "sealifebase")
  expect_true(inherits(df, "tbl"))
  expect_true(all(
    c("SpecCode", "Species", "Genus", "Family", "Order", "Class") %in%
      colnames(df)
  ))
  expect_gt(nrow(df), 0)
})
