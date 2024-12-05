test_that("parse_log() returns a tibble", {
  tmp <- fs::dir_create(fs::file_temp())
  log <- fs::file_create(fs::path(tmp, "main.log"))
  build_quick_strata_project(tmp, 2, 3)

  con <- file(log)
  sink(con, append = TRUE)
  main(tmp)
  sink()


  log_lines <-
    readLines(log)

  log_start <- stringr::str_which(log_lines, "Strata started")
  log_end <- stringr::str_which(log_lines, "Strata finished")

  log_lines <- log_lines[log_start:log_end]

  parsed_log <- parse_log(log_lines)

  expect_true(checkmate::assert_data_frame(parsed_log))
  expect_true(
    checkmate::assert_permutation(
      names(parsed_log),
      c(
        "timestamp",
        "level",
        "message"
      )
    )
  )
})
