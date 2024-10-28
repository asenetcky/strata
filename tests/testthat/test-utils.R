test_that("clean name replaces non-alphanumerics, caps and spaces", {
  expect_equal(clean_name("Hello, World!"), "hello__world_")
  expect_equal(clean_name( " H!ellO Wor^ld"), "h_ello_wor_ld")
})

test_that("check_stratum works", {
  path <- fs::file_temp()
  fs::dir_create(path)
  expect_true(check_stratum(path))
})
