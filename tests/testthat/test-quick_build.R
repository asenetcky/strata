# outline <-
  # dplyr::tibble(
  #   project_path = "~/repos/quick_build",
  #   stratum_name = "stratum1",
  #   stratum_order = 1,
  #   lamina_name = "lam1",
  #   lamina_order = 1,
  #   skip_if_fail = FALSE
  # )


# outline <-
#   dplyr::tibble(
#     project_path = "~/repos/quick_build",
#     stratum_name = c("stratum1", "stratum2"),
#     stratum_order = c(1,1),
#     lamina_name = c("lam1","lam1"),
#     lamina_order = c(1,1),
#     skip_if_fail = FALSE
#   )

test_that("build_quick_strata_project creates expected folder structure", {
  tmp <- fs::dir_create(fs::file_temp())
  result <-
    strata::build_quick_strata_project(
      project_path = tmp,
      num_strata = 3,
      num_laminae_per = 2
    ) |>
    dplyr::pull("script_path") |>
    as.character()

  expected_paths <-
    c(
      fs::path(tmp, "strata", "stratum_1", "s1_lamina_1", "my_code.R"),
      fs::path(tmp, "strata", "stratum_1", "s1_lamina_2", "my_code.R"),
      fs::path(tmp, "strata", "stratum_2", "s2_lamina_1", "my_code.R"),
      fs::path(tmp, "strata", "stratum_2", "s2_lamina_2", "my_code.R"),
      fs::path(tmp, "strata", "stratum_3", "s3_lamina_1", "my_code.R"),
      fs::path(tmp, "strata", "stratum_3", "s3_lamina_2", "my_code.R")
    ) |>
    as.character()

  what_was_created <-
    fs::dir_ls(fs::path(tmp, "strata"), recurse = TRUE, glob = "*.R") |>
    as.character()

  expect_equal(result, expected_paths)
  expect_equal(result, what_was_created)
  expect_equal(expected_paths, what_was_created)

})

test_that("build_quick_strata_project creates expected tomls", {
  expect_equal(2 * 2, 4)
})

test_that("build_quick_strata_project creates expected R files", {
  expect_equal(2 * 2, 4)
})

test_that("sourcing a quick build produces no errors", {
  expect_equal(2 * 2, 4)
})

test_that("build_outlined_strata_project creates expected folder structure", {
  expect_equal(2 * 2, 4)
})

test_that("build_outlined_strata_project creates expected tomls", {
  expect_equal(2 * 2, 4)
})

test_that("build_outlined_strata_project creates expected R files", {
  expect_equal(2 * 2, 4)
})

test_that("sourcing an outlined build produces no errors", {
  expect_equal(2 * 2, 4)
})


#this might fail because there wont be fill-in code
test_that("outlined build returns a strata survey", {
  expect_equal(2 * 2, 4)
})

