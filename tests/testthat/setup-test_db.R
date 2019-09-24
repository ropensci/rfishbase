
test_db <- file.path(tempdir(), "rfishbase")
#dir.create(test_db, showWarnings = FALSE)
Sys.setenv(FISHBASE_HOME=test_db)