ONLINE <- FALSE

test_that("We can extract the species table", {
  
  if(ONLINE){
    df <- species_table("Labroides") 
    expect_is(df, "data.frame")
  }
})
