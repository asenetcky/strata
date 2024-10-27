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
    c( "tbl_df", "tbl", "data.frame")
  )
})
