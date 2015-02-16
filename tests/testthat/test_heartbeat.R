context("heartbeat")
library("rfishbase")
library("testthat")
# test_heartbeat
test_that("API is responding", {
          needs_api()
          resp <- rfishbase:::heartbeat()
          expect_equal(resp$status_code, 200)
          })

# test_sql
test_that("MySQL server is responding", {
  needs_api()
  resp <- rfishbase:::ping()
  expect_equal(resp$status_code, 200)
})
