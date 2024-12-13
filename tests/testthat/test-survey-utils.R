test_that("scout_path returns invisible path for exisiting paths", {
  tmp <- fs::dir_create(fs::file_temp())
  expect_equal(scout_path(tmp), tmp)

  tmp_file <- fs::file_create(fs::path(tmp, "test_file.txt"))
  expect_equal(scout_path(tmp_file), tmp_file)
})

test_that("scout_path throws an error for non-existing paths", {
  tmp <- fs::path("/this/path/is/not/real/")
  expect_error(scout_path(tmp))

  tmp_file <- fs::path(tmp, "fake_file.txt")
  expect_error(scout_path(tmp_file))
})

test_that("scout_path works with a vector of same type paths", {
  tmp <- fs::dir_create(fs::file_temp())
  tmp_file <- fs::file_create(fs::path(tmp, "test_file.txt"))

  expect_equal(as.character(scout_path(c(tmp, tmp))), c(tmp, tmp))
})

test_that("scout_path works with a vector of mixed type paths", {
  tmp <- fs::dir_create(fs::file_temp())
  tmp_file <- fs::file_create(fs::path(tmp, "test_file.txt"))

  expect_equal(as.character(scout_path(c(tmp, tmp_file))), c(tmp, tmp_file))
})

test_that("scout_project returns invisble project path for quick builds", {
  tmp <- fs::dir_create(fs::file_temp())
  build_quick_strata_project(tmp)
  expect_equal(scout_project(tmp), tmp)
})

test_that("scout_project returns invisble project path for full builds", {
  tmp <- fs::dir_create(fs::file_temp())
  stratum_path <- build_stratum("test", tmp)

  build_lamina("test", stratum_path)

  expect_equal(scout_project(tmp), tmp)
})

test_that("scout_project throws an error for non-strata projects", {
  bad_path <- fs::path("/this/path/is/not/real/")
  real_path_not_project <- fs::dir_create(fs::file_temp())

  expect_error(scout_project(bad_path))
  expect_error(scout_project(real_path_not_project))
})
