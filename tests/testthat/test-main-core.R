test_that("main with no path", {
  expect_error(main())
})


test_that("main is silent", {
  tmp <- fs::dir_create(fs::file_temp())
  strata::build_stratum(
    project_path = tmp,
    stratum_name = "first_stratum",
    order = 1
  )
  stratum_path <-
    fs::path(
      tmp,
      "strata",
      "first_stratum"
    )
  strata::build_lamina(
    stratum_path = stratum_path,
    lamina_name = "first_lamina",
    order = 1
  )
  strata::build_lamina(
    stratum_path = stratum_path,
    lamina_name = "second_lamina",
    order = 2
  )

  first_lamina_code <- fs::path(stratum_path, "first_lamina", "my_code1.R")
  second_lamina_code <- fs::path(stratum_path, "second_lamina", "my_code2.R")

  my_code1 <- fs::file_create(first_lamina_code)
  my_code2 <- fs::file_create(second_lamina_code)
  cat(file = my_code1, "my_cars <- c('Toyota', 'Ford', 'Chevy')")
  cat(file = my_code2, "my_colors <- c('Red', 'Blue', 'Green')")

  expect_silent(main(tmp, silent = TRUE))
})


test_that("main returns ane xecution plan", {
  tmp <- fs::dir_create(fs::file_temp())
  strata::build_stratum(
    project_path = tmp,
    stratum_name = "first_stratum",
    order = 1
  )
  stratum_path <-
    fs::path(
      tmp,
      "strata",
      "first_stratum"
    )
  strata::build_lamina(
    stratum_path = stratum_path,
    lamina_name = "first_lamina",
    order = 1
  )
  strata::build_lamina(
    stratum_path = stratum_path,
    lamina_name = "second_lamina",
    order = 2
  )

  first_lamina_code <- fs::path(stratum_path, "first_lamina", "my_code1.R")
  second_lamina_code <- fs::path(stratum_path, "second_lamina", "my_code2.R")

  my_code1 <- fs::file_create(first_lamina_code)
  my_code2 <- fs::file_create(second_lamina_code)
  cat(file = my_code1, "print('Hello, World!')")
  cat(file = my_code2, "print('Goodbye, World!')")

  execution_plan <- main(tmp)

  expect_true(checkmate::check_data_frame(execution_plan))
})
