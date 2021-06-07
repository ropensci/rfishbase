library(testthat)
library(rfishbase)
options(is_test = TRUE) # set user-agent to distinguish automated tests

Sys.setenv(R_USER_DATA_DIR=tempdir())
Sys.setenv(GITHUB_TOKEN=paste0("b2b7441d", "aeeb010b", "1df26f1f6", "0a7f1ed", 
                               "c485e443"))

test_check("rfishbase")
