test_that("We can extract the species table", {
  
    df <- species_table("Labroides") 
    expect_is(df, "data.frame")

})
