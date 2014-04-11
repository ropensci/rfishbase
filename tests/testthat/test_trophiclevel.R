context("trophic level from HTML scraping")

  require(rfishbase)
  data(fishbase)

# Requires internet connection

test_that("we can execute getTrophicLevel", {
  response <- getTrophicLevel(fish.data[1:2])
  expect_equal(response[[1]], 2) 
})

## Should test that all the optional arguments to getTrophicLevel work as expected too...

