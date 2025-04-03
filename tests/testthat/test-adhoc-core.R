test_that("adhoc_stratum works", {
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

  stratum2_path <-
    strata::build_stratum(
      project_path = tmp,
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

  stratum2_path <-
    strata::build_stratum(
      project_path = tmp,
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

test_that("skip if fail works", {
  tmp <- fs::dir_create(fs::file_temp())

  # Build the stratum and capture path
  stratum_path <-
    strata::build_stratum(
      project_path = tmp,
      stratum_name = "first_stratum",
      order = 1
    )

  # Build the lamina
  strata::build_lamina(
    stratum_path = stratum_path,
    lamina_name = "first_lamina",
    order = 1,
    skip_if_fail = TRUE
  )

  lamina_path1 <- fs::path(stratum_path, "first_lamina")
  code_path1 <- fs::path(lamina_path1, "my_code1.R")
  my_code1 <- fs::file_create(code_path1)

  # Write code that causes an error
  cat(file = my_code1, "stop('This lamina has failed')")

  # Write code that runs in main.R after the "error"
  cat(
    file = fs::path(tmp, "main.R"),
    "print('This code should run')",
    append = TRUE
  )

  # Verify that the process doesn't throw and error
  expect_no_error(source(fs::path(tmp, "main.R")))

  # verify it throws a message
  expect_message(
    source(fs::path(tmp, "main.R")),
    regexp = "ERROR: Error in my_code1"
  )

  # verify it captures the message AFTER the error
  expect_contains(source(fs::path(tmp, "main.R")), "This code should run")
})

test_that("skip_if_fail= FALSE halts execution", {
  tmp <- fs::dir_create(fs::file_temp())

  # Build the stratum and capture path
  stratum_path <-
    strata::build_stratum(
      project_path = tmp,
      stratum_name = "first_stratum",
      order = 1
    )

  # Build the lamina
  strata::build_lamina(
    stratum_path = stratum_path,
    lamina_name = "first_lamina",
    order = 1,
    skip_if_fail = FALSE
  )

  lamina_path1 <- fs::path(stratum_path, "first_lamina")
  code_path1 <- fs::path(lamina_path1, "my_code1.R")
  my_code1 <- fs::file_create(code_path1)

  # Write code that causes an error
  cat(file = my_code1, "stop('This lamina has failed')")

  # Write code that runs in main.R after the "error"
  cat(
    file = fs::path(tmp, "main.R"),
    "print('This code should run')",
    append = TRUE
  )

  # Verify the process throws an error and halts

  expect_error(source(fs::path(tmp, "main.R")))
})


test_that("adhoc stratum throws error when path does no exists", {
  expect_error(adhoc_stratum("bad_path"))
})

test_that("adhoc lamina throws error when path does no exists", {
  expect_error(adhoc_lamina("bad_path"))
})

test_that("adhoc throws error if not interactive", {
  tmp <- fs::dir_create(fs::file_temp())
  build_quick_strata_project(tmp, 2, 2)

  expect_error(adhoc("stratum1", project_path = tmp))
})

test_that("adhoc errors with no match", {
  tmp <- fs::dir_create(fs::file_temp())
  build_quick_strata_project(tmp, 2, 2)

  expect_error(adhoc("stratum3", project_path = tmp))
})
