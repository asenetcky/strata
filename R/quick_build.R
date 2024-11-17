#' Quickly build strata project with minimal input and standard names
#'
#' @param project_path Path to the project folder
#' @param num_strata Number of strata to create
#' @param num_laminae_per Number of laminae to create per stratum
#'
#' @return invisible dataframe of the survey of the strata project
#' @export
#'
#' @examples
#' tmp <- fs::dir_create(fs::file_temp())
#' result <- build_quick_strata_project(tmp, 2, 2)
#' dplyr::glimpse(result)
build_quick_strata_project <- function(project_path,
                                       num_strata = 1,
                                       num_laminae_per = 1) {

  #create project_path if it doesn't exist
  fs::dir_create(
      project_path,
    recurse = TRUE
  )

  # outer loop create the strata
  # inner loop create the laminae per stratum
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

  # return the survey of the results
  invisible(survey_strata(project_path))
}


#' Build a strata project from an outline
#'
#' @param outline A data frame with the following columns: project_path,
#' stratum_name, stratum_order, lamina_name, lamina_order, skip_if_fail
#'
#' @return invisible dataframe of the survey of the strata project
#' @export
#'
#' @examples
#' outline <- tibble::tibble(
#'  project_path = fs::dir_create(fs::file_temp()),
#'  stratum_name = "test",
#'  stratum_order = 1,
#'  lamina_name = "test",
#'  lamina_order = 1,
#'  skip_if_fail = FALSE
#'  )
#'  result <- build_outlined_strata_project(outline)
#'  dplyr::glimpse(result)
build_outlined_strata_project <- function(outline) {
  project_path <- NULL
  outline <- check_outline(outline)

  # build the spec in the outline line by line
  purrr::walk(
    .x = seq_len(nrow(outline)),
    \(row_index) {
      build_outline_row(outline[row_index,])
    }
  )

  # return the survey of the results
  execution_plans <-
    outline |>
    dplyr::pull("project_path") |>
    unique() |>
    purrr::map(survey_strata) |>
    purrr::list_rbind()

  invisible(execution_plans)
}

check_outline <- function(outline) {

  # need to be a data frame
  checkmate::assert_data_frame(
    outline,
    ncols = 6,
    min.rows = 1L,
    any.missing = FALSE,
    all.missing = FALSE,
    types = c("project_path", "character", "numeric", "character", "numeric", "logical")
  )

  # need to have the right columns
  checkmate::assert_subset(
    names(outline),
    c(
      "project_path",
      "stratum_name",
      "stratum_order",
      "lamina_name",
      "lamina_order",
      "skip_if_fail"
    )
  )

  check_uniqueness <-
    outline |>
    dplyr::select("stratum_name", "stratum_order") |>
    purrr::map_lgl(check_unique) |>
    all()

  # strata name and order need to be unique
  checkmate::assert_true(check_uniqueness)

  outline
}

check_unique <- function(x) {
  dplyr::if_else(length(x) == length(unique(x)), TRUE, FALSE)
}


build_outline_row <- function(outline_row) {

  #check if stratum exists and handle it
  stratum_path <-
    fs::path(
      outline_row$project_path,
      "strata",
      outline_row$stratum_name
    )

  stratum_exist <- fs::dir_exists(stratum_path)

  if (!stratum_exist) {
    build_stratum(
      stratum_name = outline_row$stratum_name,
      path = outline_row$project_path,
      order = outline_row$stratum_order
    )
  }

  lamina_path <-
    fs::path(
      stratum_path,
      outline_row$lamina_name
    )

  # check if lamina exists and handle it
  lamina_exist <- fs::dir_exists(lamina_path)

  if(!lamina_exist) {
    build_lamina(
      lamina_name = outline_row$lamina_name,
      stratum_path = stratum_path,
      order = outline_row$lamina_order,
      skip_if_fail = outline_row$skip_if_fail
    )
  }
  invisible(TRUE)
}
