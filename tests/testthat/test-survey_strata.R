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
