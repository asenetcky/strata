test_that("execution plan is as expected", {
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
    dplyr::mutate(
      intended_order = substr(
        x = lamina_name,
        start = nchar(lamina_name),
        stop = nchar(lamina_name)
      ) |>
        as.integer()
    )

  expect_identical(survey$execution_order, survey$intended_order)
})


test_that("strata execute based on strata order", {
  tmp <- fs::dir_create(fs::file_temp())

  s1 <- strata::build_stratum("dp", project_path = tmp, order = 1)

  strata::build_lamina("si", s1)

  s2 <- strata::build_stratum("da", project_path = tmp, order = 2)
  strata::build_lamina("p", s2, order = 1)
  strata::build_lamina("w", s2, order = 2)
  strata::build_lamina("d", s2, order = 3)
  strata::build_lamina("sq", s2, order = 4)

  first_code <- fs::path(s1, "si", "my_code1.R")
  second_code <- fs::path(s2, "p", "my_code2.R")
  third_code <- fs::path(s2, "w", "my_code3.R")
  fourth_code <- fs::path(s2, "d", "my_code4.R")
  fifth_code <- fs::path(s2, "sq", "my_code5.R")

  c(first_code, second_code, third_code, fourth_code, fifth_code) |>
    purrr::walk(fs::file_create)

  survey <-
    survey_strata(tmp)

  fs::dir_delete(tmp)

  slice <- survey |> dplyr::select(execution_order, stratum_name, lamina_name)

  expected <-
    tibble::tibble(
      execution_order = c(1, 2, 3, 4, 5),
      stratum_name = c("dp", "da", "da", "da", "da"),
      lamina_name = c("si", "p", "w", "d", "sq")
    )

  expect_equal(slice, expected)
})
