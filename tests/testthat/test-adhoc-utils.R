# test adhoc checks
test_that("adhoc_check returns a path", {
  tmp <- fs::dir_create(fs::file_temp())
  build_quick_strata_project(tmp)

  path <- adhoc_check(name = "test", project_path = tmp)
  expect_identical(path, tmp)
})

test_that("adhoc_check errors appropriately", {
  tmp <- fs::dir_create(fs::file_temp())
  build_quick_strata_project(tmp)

  # test for name
  expect_error(adhoc_check(name = 123, project_path = tmp))

  # test for project_path
  expect_error(adhoc_check(name = "test", project_path = 123))

  # test for prompt
  expect_error(
    adhoc_check(name = "test", project_path = tmp, prompt = 123)
  )
})

# test adhoc_matches
test_that("adhoc_matches returns tibble", {
  tmp <- fs::dir_create(fs::file_temp())
  build_quick_strata_project(tmp, 3, 2)

  plan <- build_execution_plan(tmp)

  matches <- adhoc_matches(name = "stratum_2", execution_plan = plan)
  expect_true(checkmate::check_data_frame(matches))
})

test_that("adhoc_matches returns empty tiblle", {
  tmp <- fs::dir_create(fs::file_temp())
  build_quick_strata_project(tmp, 3, 2)

  plan <- build_execution_plan(tmp)

  matches <- adhoc_matches(name = "stratum_4", execution_plan = plan)
  expect_true(checkmate::check_data_frame(matches))
  expect_true(nrow(matches) == 0)
})

# test adhoc_freewill
test_that("adhoc freewill picks for user", {
  tmp <- fs::dir_create(fs::file_temp())

  # stratum
  s1_path <- build_stratum("test1", tmp, 1)
  s2_path <- build_stratum("test2", tmp, 2)

  # lamina
  build_lamina("l1", s1_path)
  build_lamina("l1", s2_path)

  # add code to laminae
  code_path <- fs::path(s1_path, "l1", "code.R")
  code <- fs::file_create(code_path)
  cat(file = code, "print('Hello, World!')")

  code_path <- fs::path(s2_path, "l1", "code.R")
  code <- fs::file_create(code_path)
  cat(file = code, "print('Hello, World!')")

  plan <- build_execution_plan(tmp)

  matches <- adhoc_matches(name = "l1", plan)

  match_one <-
    adhoc_freewill(distinct_matches = matches, prompt = FALSE)

  expect_identical(matches[1, ], match_one)
})
