# Test cases for log_message function
test_that("log message has no error", {
  expect_no_error(log_message("hello"))
})

test_that("log_message and log_error to stderr", {
  expect_message(log_message("hello", out_or_err = "ERR"))
  expect_message(log_error("hello"))
})


test_that("log_total_time works", {
  begin <- Sys.time()
  end <- begin + 100
  expect_equal(log_total_time(begin, end), 100)
})

test_that("log_total_time throws error", {
  expect_error(log_total_time("hello", "world"))
})
