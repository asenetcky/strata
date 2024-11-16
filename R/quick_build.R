# and then maybe another fun where the user passes a tibble of stratum_name,
# stratum_order, lamina_name, lamina_order,
# and skip_if_fail as optional(revert to default FALSE)

quick_build_strata_project <- function(project_path,
                                       num_strata = 1,
                                       num_laminae_per = 1) {

  #create project_path if it doesn't exist
  fs::dir_create(
      project_path,
    recurse = TRUE
  )




  purrr::walk(
    .x = seq_along(1:num_strata),
    \(outer_index) {
      stratum_path <- build_stratum(
        path = project_path,
        stratum_name = paste0("stratum_", outer_index),
        order = outer_index
      )

      purrr::walk(
        .x = seq_along(1:num_laminae_per),
        \(inner_index) {
          name <- paste0("s", outer_index, "_lamina_", inner_index)

          strata::build_lamina(
            stratum_path = stratum_path,
            lamina_name = name,
            order = inner_index
          )

          lamina_code <- fs::path(stratum_path, name, "my_code.R")
          my_code <- fs::file_create(lamina_code)
          cat(file = my_code, "print('Hello, World!')")
        }
      )
    }
  )
  invisible(project_path)
}

build_outline <- function(outline) {
  # check outline
  # build project to spec
}

check_outline <- function(outline) {
  checkmate::assert_data_frame(
    outline,
    ncols = 5,
    min.rows = 1L,
    any.missing = FALSE,
    all.missing = FALSE,
    types = c("character", "numeric", "character", "numeric", "logical")
  )

  checkmate::assert_subset(
    names(outline),
    c(
      "stratum_name",
      "stratum_order",
      "lamina_name",
      "lamina_order",
      "skip_if_fail"
    )
  )

  check <-
    outline |>
    dplyr::select(-skip_if_fail) |>
    purrr::map_lgl(check_unique) |>
    all()

  checkmate::assert_true(check)
}

check_unique <- function(x) {
  dplyr::if_else(length(x) == length(unique(x)), TRUE, FALSE)
}

# outline <-
  # dplyr::tibble(
  #   stratum_name = "stratum1",
  #   stratum_order = 1,
  #   lamina_name = "lam1",
  #   lamina_order = 1,
  #   skip_if_fail = FALSE
  # )
