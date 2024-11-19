test_that("stratum built", {
  tmp <- fs::dir_create(fs::file_temp())
  strata::build_stratum(
    project_path = tmp,
    stratum_name = "first_stratum",
    order = 1
  )
  expect_true(fs::dir_exists(fs::path(tmp, "strata", "first_stratum")))
})

test_that("lamina built", {
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
  expect_true(fs::dir_exists(fs::path(stratum_path, "first_lamina")))
})


test_that("main built and runs", {
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

  lamina_path1 <- fs::path(stratum_path, "first_lamina")
  lamina_path2 <- fs::path(stratum_path, "second_lamina")
  code_path1 <- fs::path(lamina_path1, "my_code1.R")
  code_path2 <- fs::path(lamina_path2, "my_code2.R")

  my_code1 <- fs::file_create(code_path1)
  my_code2 <- fs::file_create(code_path2)
  cat(file = my_code1, "print('Hello, World!')")
  cat(file = my_code2, "print('Goodbye, World!')")

  source(fs::path(tmp, "main.R"))
  expect_true(TRUE)
})


test_that("build_stratum creates the initial toml", {
  tmp <- fs::dir_create(fs::file_temp())
  strata::build_stratum(
    project_path = tmp,
    stratum_name = "first_stratum",
    order = 1
  )
  expect_true(fs::file_exists(fs::path(tmp, "strata", ".strata.toml")))
  expect_equal(
    snapshot_toml(fs::path(tmp, "strata", ".strata.toml"))$name,
    "first_stratum"
  )
  expect_equal(
    snapshot_toml(fs::path(tmp, "strata", ".strata.toml"))$order,
    1
  )
  expect_equal(
    snapshot_toml(fs::path(tmp, "strata", ".strata.toml"))$type,
    "strata"
  )
})


test_that("build_lamina creates the initial toml", {
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
  expect_true(fs::file_exists(fs::path(stratum_path, ".laminae.toml")))
  expect_equal(
    snapshot_toml(fs::path(stratum_path, ".laminae.toml"))$name,
    "first_lamina"
  )
  expect_equal(
    snapshot_toml(fs::path(stratum_path, ".laminae.toml"))$order,
    1
  )
  expect_equal(
    snapshot_toml(fs::path(stratum_path, ".laminae.toml"))$type,
    "laminae"
  )
})

test_that("clean name replaces non-alphanumerics, caps and spaces", {
  expect_equal(clean_name("Hello, World!"), "hello__world_")
  expect_equal(clean_name(" H!ellO Wor^ld"), "h_ello_wor_ld")
})
