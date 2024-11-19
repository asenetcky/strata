test_that("returns invisble path upon success", {
  path <- fs::file_temp()
  fs::dir_create(path)
  expect_equal(
    initial_lamina_toml(path),
    fs::path(path, ".laminae.toml")
  )

  expect_equal(
    initial_stratum_toml(path = path, name = "test", order = 1),
    fs::path(path, ".strata.toml")
  )
})

test_that("returns a dataframe", {
  path <- fs::file_temp()
  fs::dir_create(path)
  toml_path <- initial_stratum_toml(path = path, name = "test", order = 1)
  initial_lamina_toml(path)
  expect_equal(
    class(snapshot_toml(toml_path)),
    c("tbl_df", "tbl", "data.frame")
  )
})


test_that("fixes order", {
  toml_snapshot <-
    tibble::tibble(
      type = "laminae",
      name = "test",
      order = c(1, 2, 3, 4, 5),
      skip_if_fail = c("FALSE", "FALSE", "FALSE", "FALSE", "FALSE"),
      created = Sys.Date()
    )

  expect_equal(
    manage_toml_order(toml_snapshot)$order,
    c(1, 2, 3, 4, 5)
  )

  toml_snapshot <- tibble::tibble(
    type = "strata",
    name = "test",
    order = c(1, 2, 3, 4, 4),
    created = Sys.Date()
  )

  expect_equal(
    manage_toml_order(toml_snapshot)$order,
    c(1, 2, 3, 4, 5)
  )
})




test_that("find_tomls finds all the tomls", {
  path <- fs::file_temp()
  fs::dir_create(path)

  stratum_path <-
    build_stratum(project_path = path, stratum_name = "test", order = 1)

  toml_path <- fs::path(
    fs::path_dir(stratum_path),
    ".strata.toml"
  )

  expect_equal(
    as.character(find_tomls(path)),
    as.character(toml_path)
  )

  build_lamina(
    stratum_path = stratum_path,
    lamina_name = "test",
    order = 1
  )

  expect_equal(
    as.character(find_tomls(path)),
    c(toml_path, fs::path(stratum_path, ".laminae.toml")) |> as.character()
  )
})

test_that("write, read and rewrite are identical", {
  path <- fs::file_temp()
  fs::dir_create(path)
  toml_path <-
    initial_stratum_toml(path = path, name = "test", order = 1)

  toml_snapshot <- snapshot_toml(toml_path)

  rewrite_from_dataframe(toml_snapshot, toml_path)
  expect_equal(
    snapshot_toml(toml_path),
    toml_snapshot
  )
})
