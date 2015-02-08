test_that("We can extract generic information from the species table", {
  
    df <- species_info(c("Oreochromis niloticus", "Bolbometopon muricatum")) 
    expect_is(df, "data.frame")

})

test_that("We can pass a species_list based on taxanomic group", {
  
  fish <- species_list(Family = "Labroides") 
  df <- species_info(fish)
  expect_is(df, "data.frame")
  
})
