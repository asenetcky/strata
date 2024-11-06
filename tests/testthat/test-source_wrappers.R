test_that("adhoc_stratum works", {
  tmp <- fs::dir_create(fs::file_temp())
  strata::build_stratum(
    path = tmp,
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


  stratum2_path <-
    strata::build_stratum(
      path = tmp,
      stratum_name = "bad_stratum",
      order = 2
    )


  strata::build_lamina(
    stratum_path = stratum2_path,
    lamina_name = "bad_apple",
    order = 1
  )


  bad_apple_path <- fs::path(stratum2_path, "bad_apple", "bad_code.R")
  bad_apple <- fs::file_create(bad_apple_path)
  cat(file = bad_apple, "stop('test failed')")

  expect_error(adhoc_stratum(stratum2_path))
  expect_error(main(tmp))
  expect_no_error(adhoc_stratum(stratum_path))

})

test_that("adhoc_lamina works", {
  tmp <- fs::dir_create(fs::file_temp())
  strata::build_stratum(
    path = tmp,
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


  stratum2_path <-
    strata::build_stratum(
      path = tmp,
      stratum_name = "bad_stratum",
      order = 2
    )


  strata::build_lamina(
    stratum_path = stratum2_path,
    lamina_name = "bad_apple",
    order = 1
  )


  bad_apple_path <- fs::path(stratum2_path, "bad_apple", "bad_code.R")
  bad_apple <- fs::file_create(bad_apple_path)
  cat(file = bad_apple, "stop('test failed')")

  expect_error(main(tmp))
  expect_error(adhoc_lamina(fs::path(tmp, "strata/bad_stratum/bad_apple")))

  expect_no_error(adhoc_lamina(fs::path(stratum_path, "first_lamina")))
  expect_no_error(adhoc_lamina(fs::path(stratum_path, "second_lamina")))

})

