context("taxonomy")

test_that('returns a data.frame with correct sciname', {
  needs_api()
  
  aa <- suppressWarnings(taxonomy("Oreochromis", "amphimelas"))
  expect_is(aa, "data.frame")
  expect_equal(aa$sciname, "Oreochromis amphimelas")
  expect_equal(NROW(aa), 1)
  
  bb <- suppressWarnings(taxonomy("Oreochromis"))
  expect_is(bb, "data.frame")
  expect_gt(NROW(bb), 10)
})
