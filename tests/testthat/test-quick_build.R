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

test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})
