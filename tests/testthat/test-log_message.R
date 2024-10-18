# Test cases for log_message function
test_that("log message has no error", {
  expect_no_error(log_message("hello"))
})

test_that("log message to stderr", {
  expect_message(log_message("hello", out_or_err = "ERR"))
})
