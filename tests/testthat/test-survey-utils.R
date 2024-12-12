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

  expect_equal(scout_path(c(tmp, tmp)), c(tmp, tmp))
})

test_that("scout_path works with a vector of mixed type paths", {
  tmp <- fs::dir_create(fs::file_temp())
  tmp_file <- fs::file_create(fs::path(tmp, "test_file.txt"))

  expect_equal(scout_path(c(tmp, tmp_file)), c(tmp, tmp_file))
})
