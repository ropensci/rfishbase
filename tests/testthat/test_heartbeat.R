
library("rfishbase")
library("testthat")
# test_heartbeat
test_that("API is responding",
          {
          resp <- rfishbase:::heartbeat()
          expect_equal(resp$status_code, 200)
          })

# test_sql
test_that("MySQL server is responding",
{
  resp <- rfishbase:::ping()
  expect_equal(resp$status_code, 200)
})