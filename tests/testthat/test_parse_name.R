context("parse_name")

test_that("parse_name identfies numeric as speccode", {
  s <- parse_name(1234)
  expect_null(s$genus)
  expect_null(s$species)
  expect_is(s$speccode, "integer")
})

test_that("parse_name identfies quoted integer as speccode", {
  s <- parse_name("1234")
  expect_null(s$genus)
  expect_null(s$species)
  expect_is(s$speccode, "integer")
})

test_that("parse_name identfies scientific name", {
  s <- parse_name("genus species")
  expect_null(s$speccode)
  expect_is(s$species, "character")
  expect_equal(s$species, "species")
  expect_is(s$genus, "character")
  expect_equal(s$genus, "genus")
})

test_that("parse_name identfies scientific name", {
  ## not a valid format.   
  expect_warning(
    expect_null(
      parse_name("genus-species")[[1]] ))
})