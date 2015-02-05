# test_heartbeat
test_that("API has heartbeat",
          {
          resp <- rfishbase:::heartbeat()
          expect_equal(resp$status_code, 200)
          })

# test_sql