context("maturity")

test_that('returns a data.frame with correct sciname', 
          {
            needs_api()
            expect_true("Epinephelus morio" %in% maturity("Epinephelus morio")$Species)
          }
          )