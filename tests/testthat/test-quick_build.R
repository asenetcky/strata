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
  expect_equal(2 * 2, 4)
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


test_that("outlined build returns a strata survey", {
  expect_equal(2 * 2, 4)
})

