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
  tmp <- fs::dir_create(fs::file_temp())
  result <-
    strata::build_quick_strata_project(
      project_path = tmp,
      num_strata = 3,
      num_laminae_per = 2
    )

  tomls_paths <- survey_tomls(tmp) |> as.character()
  expected_toml_paths <-
    c(
      fs::path(tmp, "strata", ".strata.toml"),
      fs::path(tmp, "strata", "stratum_1", ".laminae.toml"),
      fs::path(tmp, "strata", "stratum_2", ".laminae.toml"),
      fs::path(tmp, "strata", "stratum_3", ".laminae.toml")
    ) |>
    as.character()

  expect_equal(tomls_paths, expected_toml_paths)
})


test_that("build_outlined_strata_project creates expected folder structure", {
  tmp <- fs::dir_create(fs::file_temp())
  outline <-
    dplyr::tibble(
      project_path = tmp,
      stratum_name = "stratum1",
      stratum_order = 1,
      lamina_name = "lam1",
      lamina_order = 1,
      skip_if_fail = FALSE
    )

  result <-
    strata::build_outlined_strata_project(outline) |>
    dplyr::pull("script_path") |>
    as.character()

  expected_paths <-
    c(
      fs::path(
        outline$project_path, "strata", "stratum1", "lam1", "my_code.R"
      )
    ) |>
    as.character()

  what_was_created <-
    fs::dir_ls(
      fs::path(outline$project_path, "strata"),
      recurse = TRUE, glob = "*.R"
    ) |>
    as.character()

  expect_equal(result, expected_paths)
  expect_equal(result, what_was_created)
  expect_equal(expected_paths, what_was_created)
})

test_that("build_outlined_strata_project creates expected tomls", {
  tmp <- fs::dir_create(fs::file_temp())
  outline <-
    dplyr::tibble(
      project_path = tmp,
      stratum_name = "stratum1",
      stratum_order = 1,
      lamina_name = "lam1",
      lamina_order = 1,
      skip_if_fail = FALSE
    )

  expected_tomls <-
    c(
      fs::path(tmp, "strata", ".strata.toml"),
      fs::path(tmp, "strata", "stratum1", ".laminae.toml")
    ) |>
    as.character()

  result <- strata::build_outlined_strata_project(outline)
  survey <- survey_tomls(tmp) |> as.character()
  expect_equal(survey, expected_tomls)
})

test_that("build_outlined_strata_project creates expected R files", {
  tmp <- fs::dir_create(fs::file_temp())
  outline <-
    dplyr::tibble(
      project_path = tmp,
      stratum_name = c("stratum1", "stratum2", "stratum3"),
      stratum_order = c(1:3),
      lamina_name = c("lam1", "lam2", "lam3"),
      lamina_order = c(1:3),
      skip_if_fail = FALSE
    )

  result <- strata::build_outlined_strata_project(outline)
  files_exist <-
    fs::file_exists(result$script_path) |>
    all()
  expect_true(files_exist)
})


test_that("outlined build returns a strata survey", {
  tmp <- fs::dir_create(fs::file_temp())
  outline <-
    dplyr::tibble(
      project_path = tmp,
      stratum_name = c("stratum1", "stratum2", "stratum3"),
      stratum_order = c(1:3),
      lamina_name = c("lam1", "lam2", "lam3"),
      lamina_order = c(1:3),
      skip_if_fail = FALSE
    )

  result <- strata::build_outlined_strata_project(outline)
  expect_equal(result, survey_strata(tmp))
})


test_that("outlined build allows multiple lamina per stratum", {
  tmp <- fs::dir_create(fs::file_temp())

  outline <-
    dplyr::tibble(
      project_path = tmp,
      stratum_name = c(
        rep("data_pull", 3),
        "data_wrangle",
        rep("build_model", 2),
        "build_report"
      ),
      stratum_order = c(
        rep(1, 3),
        2,
        rep(3, 2),
        4
      ),
      lamina_name = c(
        "connections",
        "authenticaiton",
        "sql",
        "clean_data",
        "tidy_models",
        "host_model",
        "quarto_report"
      ),
      lamina_order = c(1, 2, 3, 1, 1, 2, 1),
      skip_if_fail = FALSE
    )

  expect_no_error(
    build_outlined_strata_project(outline)
  )

  created_paths <-
    survey_strata(tmp) |>
    dplyr::pull("script_path") |>
    fs::path_dir() |>
    fs::as_fs_path()

  expected_paths <-
    fs::path(
      outline$project_path,
      "strata",
      outline$stratum_name,
      outline$lamina_name
    )

  expect_true(
    checkmate::check_subset(
      created_paths,
      expected_paths
    )
  )
})

test_that("outlined build fails with non-unique strata/laminae name combos", {
  tmp <- fs::dir_create(fs::file_temp())

  outline <-
    dplyr::tibble(
      project_path = tmp,
      stratum_name = c(
        rep("data_pull", 3),
        "data_wrangle",
        rep("build_model", 2),
        "build_report"
      ),
      stratum_order = c(
        rep(1, 3),
        2,
        rep(3, 2),
        4
      ),
      lamina_name = c(
        "connections",
        "connections",
        "sql",
        "clean_data",
        "tidy_models",
        "host_model",
        "quarto_report"
      ),
      lamina_order = c(1, 2, 3, 1, 1, 2, 1),
      skip_if_fail = FALSE
    )

  expect_error(
    build_outlined_strata_project(outline)
  )
})


test_that("outlined build allows multiple lamina per stratum", {
  tmp <- fs::dir_create(fs::file_temp())

  outline <-
    dplyr::tibble(
      project_path = tmp,
      stratum_name = c(
        rep("data_pull", 3),
        "data_wrangle",
        rep("build_model", 2),
        "build_report"
      ),
      stratum_order = c(
        rep(1, 3),
        2,
        rep(3, 2),
        4
      ),
      lamina_name = c(
        "connections",
        "authenticaiton",
        "sql",
        "clean_data",
        "tidy_models",
        "host_model",
        "quarto_report"
      ),
      lamina_order = c(1, 2, 3, 1, 1, 2, 1),
      skip_if_fail = FALSE
    )

  expect_no_error(
    build_outlined_strata_project(outline)
  )

  created_paths <-
    survey_strata(tmp) |>
    dplyr::pull("script_path") |>
    fs::path_dir() |>
    fs::as_fs_path()

  expected_paths <-
    fs::path(
      outline$project_path,
      "strata",
      outline$stratum_name,
      outline$lamina_name
    )

  expect_true(
    checkmate::check_subset(
      created_paths,
      expected_paths
    )
  )
})

test_that("outlined build fails with non-unique strata/laminae name combos", {
  tmp <- fs::dir_create(fs::file_temp())

  outline <-
    dplyr::tibble(
      project_path = tmp,
      stratum_name = c(
        rep("data_pull", 3),
        "data_wrangle",
        rep("build_model", 2),
        "build_report"
      ),
      stratum_order = c(
        rep(1, 3),
        2,
        rep(3, 2),
        4
      ),
      lamina_name = c(
        "connections",
        "connections",
        "sql",
        "clean_data",
        "tidy_models",
        "host_model",
        "quarto_report"
      ),
      lamina_order = c(1, 2, 3, 1, 1, 2, 1),
      skip_if_fail = FALSE
    )

  expect_error(
    build_outlined_strata_project(outline)
  )
})
