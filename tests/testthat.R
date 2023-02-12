library(testthat)
library(rfishbase)
#options(is_test = TRUE) # set user-agent to distinguish automated tests
#Sys.setenv(R_USER_DATA_DIR=tempdir())


test_check("rfishbase")
