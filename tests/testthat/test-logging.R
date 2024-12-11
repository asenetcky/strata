# Test cases for log_message function
test_that("log message has no error", {
  log_message_runs_message <- log_message("hello")
  message <- stringr::str_sub(log_message_runs_message, 28)
  expect_equal(message, "INFO: hello")
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

test_that("log_message returns invisible string", {
  captured_log <- log_message("testing, 1, 2, 3")
  expect_true(
    checkmate::check_string(captured_log, n.chars = 49)
  )
})

test_that("log_error returns invisible string", {
  captured_log <- log_error("ahhh, panic!")
  expect_true(
    checkmate::check_string(captured_log, n.chars = 46)
  )
})
