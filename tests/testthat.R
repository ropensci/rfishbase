library(testthat)
library(rfishbase)
options(is_test = TRUE) # set user-agent to distinguish automated tests

needs_api <- function() NULL
test_check("rfishbase")
