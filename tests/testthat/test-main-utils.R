test_that("execution plan is as expected", {
  tmp <- fs::dir_create(fs::file_temp())
  strata::build_stratum(
    project_path = tmp,
    stratum_name = "first_stratum",
    order = 1
  )
  stratum_path <-
    fs::path(
      tmp, "strata", "first_stratum"
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
  expect_equal(
    execution_plan |> dplyr::mutate(path = as.character(path)),
    tibble::tibble(
      stratum = c("first_stratum", "first_stratum"),
      lamina = c("first_lamina", "second_lamina"),
      order = c(1, 2),
      skip_if_fail = c(FALSE, FALSE),
      created = Sys.Date(),
      script = c("my_code1", "my_code2"),
      path = c(first_lamina_code, second_lamina_code)
    )
  )
})

test_that("order isn't bonkers", {
  tmp <- fs::dir_create(fs::file_temp())

  build_quick_strata_project(tmp, 9, 9)

  survey <-
    survey_strata(tmp) |>
    dplyr::select(execution_order, stratum_name, lamina_name) |>
    dplyr::filter(stratum_name == "stratum_1") |>
    dplyr::mutate(intended_order = substr(
      x = lamina_name,
      start = nchar(lamina_name),
      stop = nchar(lamina_name)
    ) |>
      as.integer())

  expect_identical(survey$execution_order, survey$intended_order)
})
