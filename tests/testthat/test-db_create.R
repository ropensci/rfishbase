context("db_create")

test_that("we can create the local db for a specified tbl", {
  db_create("brains")
  eco <- fb_tbl("ecology")
  expect_is(eco, "tbl")
})