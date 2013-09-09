
require(rfishbase)
data(fishbase)

test_that("We can download a length-weight table", {
  out <- getLengthWeight(fish.data[1])
  expect_is(out[[1]], "data.frame")
})
