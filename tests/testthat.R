library(testthat)
library(rfishbase)
options(is_test = TRUE) # set user-agent to distinguish automated tests
test_check("rfishbase")
