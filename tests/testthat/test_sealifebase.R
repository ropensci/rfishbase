testthat::context("sealifebase")

testthat::test_that("We get taxa table from sealifebase", {
  needs_api()
  crabs <- common_to_sci("king crab", server = "https://fishbase.ropensci.org/sealifebase")
  testthat::expect_true("Limulus polyphemus" %in% crabs)
})



test_that("Sealifebase species are matched",{
  needs_api()  
  df_s <- species("Homarus americanus", 
                  server = "https://fishbase.ropensci.org/sealifebase")
  df_d <- species(c("Homarus americanus", "Homarus americanus"), 
                  server = "https://fishbase.ropensci.org/sealifebase")
  df_dm <- species(c("Homarus americanus", "Homarus americanus", "foo"),
                   server = "https://fishbase.ropensci.org/sealifebase")
  
  expect_equal(nrow(df_s), nrow(df_d))
  expect_equal(nrow(df_s), nrow(df_dm))
})
