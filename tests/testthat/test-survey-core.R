test_that("survey_strata returns a dataframe", {
  project_path <- fs::file_temp()
  fs::dir_create(project_path)

  stratum_path <- build_stratum(
    project_path = project_path,
    stratum_name = "first_stratum",
    order = 1
  )

  build_lamina(
    lamina_name = "first_lamina",
    stratum_path = stratum_path,
    order = 1
  )

  code_path <- fs::path(stratum_path, "first_lamina", "my_code.R")
  my_code <- fs::file_create(code_path)
  cat(file = my_code, "print('Hello, World!')")

  expect_no_error(survey_strata(project_path))

  survey <- survey_strata(project_path)
  expect_s3_class(survey, "data.frame")
})

test_that("survey_log() returns a tibble", {
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
  writeLines(log_lines, log)

  surveyed_log <- survey_log(log)

  expect_true(checkmate::check_data_frame(surveyed_log))
  expect_true(
    checkmate::check_permutation(
      names(surveyed_log),
      c(
        "line_number",
        "timestamp",
        "level",
        "message"
      )
    )
  )
})

test_that("survey_log() ignores non-log output", {
  tmp <- fs::dir_create(fs::file_temp())
  log <- fs::file_create(fs::path(tmp, "main.log"))
  build_quick_strata_project(tmp, 2, 3)

  cat(
    "print('IGNORE ME')",
    file = fs::path(
      tmp,
      "strata",
      "stratum_2",
      "s2_lamina_2",
      "my_code.R"
    )
  )

  con <- file(log)
  sink(con, append = TRUE)
  main(tmp)
  sink()

  log_lines <-
    readLines(log)

  log_start <- stringr::str_which(log_lines, "Strata started")
  log_end <- stringr::str_which(log_lines, "Strata finished")

  log_lines <- log_lines[log_start:log_end]
  writeLines(log_lines, log)

  surveyed_log <- survey_log(log)

  expect_true(
    all(!stringr::str_detect(surveyed_log$message, "IGNORE ME"))
  )
})


test_that("survey_tomls finds all the tomls", {
  path <- fs::file_temp()
  fs::dir_create(path)

  stratum_path <-
    build_stratum(project_path = path, stratum_name = "test", order = 1)

  toml_path <- fs::path(
    fs::path_dir(stratum_path),
    ".strata.toml"
  )

  build_lamina(
    stratum_path = stratum_path,
    lamina_name = "test",
    order = 1
  )

  expect_equal(
    as.character(survey_tomls(path)),
    c(toml_path, fs::path(stratum_path, ".laminae.toml")) |> as.character()
  )
})


test_that("survey_log throw error on empty log", {
  tmp <- fs::dir_create(fs::file_temp())
  empty_log <- fs::file_create(fs::path(tmp, "empty.log"))
  expect_error(survey_log(empty_log))
})
