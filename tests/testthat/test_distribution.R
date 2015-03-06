context("locations")

test_that("We can query locations", {
  needs_api()
  
  sp <- c("Labroides bicolor",  "Labroides dimidiatus", "Labroides pectoralis", "Labroides phthirophagus", "Labroides rubrolabiatus")
  df <- distribution(sp)
  expect_is(df, "data.frame")
  
})