test_that("survey_tomls finds all the tomls", {
  path <- fs::file_temp()
  fs::dir_create(path)

  stratum_path <-
    build_stratum(project_path = path, stratum_name = "test", order = 1)

  toml_path <- fs::path(
    fs::path_dir(stratum_path),
    ".strata.toml"
  )

  expect_equal(
    as.character(survey_tomls(path)),
    as.character(toml_path)
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

test_that("view_toml returns a dataframe", {
  path <- fs::file_temp()
  fs::dir_create(path)
  toml_path <- initial_stratum_toml(path = path, name = "test", order = 1)
  initial_lamina_toml(path)
  expect_equal(
    class(view_toml(toml_path)),
    c("tbl_df", "tbl", "data.frame")
  )
})

test_that("edit_toml works on strata toml", {
  path <- fs::file_temp()
  fs::dir_create(path)

  toml_path <- initial_stratum_toml(path = path, name = "test", order = 1)
  initial_lamina_toml(path)

  old_toml <- view_toml(toml_path)

  new_toml <-
    old_toml |>
    dplyr::mutate(name = "new_name")

  edit_toml(
    original_toml_path = toml_path,
    new_toml_dataframe = new_toml
  )

  expect_equal(
    new_toml,
    view_toml(toml_path)
  )

  backup_path <- fs::path(path, ".strata.bak")
  expect_true(
    fs::file_exists(backup_path)
  )
})


test_that("edit_toml works on lamina toml", {
  path <- fs::file_temp()
  fs::dir_create(path)

  toml_path <- initial_stratum_toml(path = path, name = "test", order = 1)

  build_lamina(
    stratum_path = path,
    lamina_name = "test",
    order = 1
  )

  lamina_toml <-
    fs::path(
      path,
      ".laminae.toml"
    )

  old_toml <- view_toml(lamina_toml)

  new_toml <-
    old_toml |>
    dplyr::mutate(name = "new_name")

  edit_toml(
    original_toml_path = lamina_toml,
    new_toml_dataframe = new_toml
  )

  expect_equal(
    new_toml,
    view_toml(lamina_toml)
  )

  backup_path <- fs::path(path, ".laminae.bak")
  expect_true(
    fs::file_exists(backup_path)
  )
})


test_that("check_toml_dataframe manages order", {
  toml_snapshot <-
    tibble::tibble(
      type = "strata",
      name = "test",
      order = c(1, 2, 3, 4, 4),
      created = Sys.Date()
    )

  expect_equal(
    check_toml_dataframe(toml_snapshot)$order,
    c(1, 2, 3, 4, 5)
  )
})

test_that("check_toml_dataframe drops bad columns", {
  toml_snapshot <-
    tibble::tibble(
      type = "strata",
      name = "test",
      bad_column0 = "test",
      order = c(1, 2, 3, 4, 5),
      created = Sys.Date(),
      bad_column1 = "test",
      bad_column2 = "test",
      bad_column3 = "test"
    )

  expected_toml_snapshot <-
    tibble::tibble(
      type = "strata",
      name = "test",
      order = c(1, 2, 3, 4, 5),
      created = Sys.Date()
    )

  expect_equal(
    check_toml_dataframe(toml_snapshot),
    expected_toml_snapshot
  )
})

test_that("check_toml_dataframe errors with missing columns", {
  toml_snapshot <-
    tibble::tibble(
      type = "strata",
      name = "test",
      order = c(1, 2, 3, 4, 5)
    )

  expect_error(check_toml_dataframe(toml_snapshot))
})

test_that("check_toml_dataframe works with strata", {
  toml_snapshot <-
    tibble::tibble(
      type = "strata",
      name = "test",
      order = c(1, 2, 3, 4, 5),
      created = Sys.Date()
    )

  expected_toml_snapshot <- toml_snapshot

  expect_equal(
    check_toml_dataframe(toml_snapshot),
    expected_toml_snapshot
  )
})

test_that("check_toml_dataframe works with laminae", {
  toml_snapshot <-
    tibble::tibble(
      type = "laminae",
      name = "test",
      order = c(1, 2, 3, 4, 5),
      skip_if_fail = FALSE,
      created = Sys.Date()
    )

  expected_toml_snapshot <- toml_snapshot

  expect_equal(
    check_toml_dataframe(toml_snapshot),
    expected_toml_snapshot
  )
})

test_that("check_toml_dataframe returns a dataframe", {
  toml_snapshot <-
    tibble::tibble(
      type = "strata",
      name = "test",
      order = c(1, 2, 3, 4, 5),
      created = Sys.Date()
    )

  expect_equal(
    class(check_toml_dataframe(toml_snapshot)),
    c("tbl_df", "tbl", "data.frame")
  )
})
