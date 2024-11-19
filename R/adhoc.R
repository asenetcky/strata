#' Run a stratum adhoc by itself
#'
#' @param stratum_path Path to stratum
#' @param silent Suppress log output
#'
#' @return invisible data frame of execution plan
#' @export
#'
#' @examples
#' tmp <- fs::dir_create(fs::file_temp())
#' result <- strata::build_quick_strata_project(tmp, 1, 1)
#' adhoc_stratum(
#'   fs::path(tmp, "strata", "stratum_1"),
#' )
#' @importFrom rlang .data
adhoc_stratum <- function(stratum_path, silent = FALSE) {
  stratum_name <- fs::path_file(stratum_path)
  project_path <-
    fs::path_dir(
      fs::path_dir(stratum_path)
    )

  if (fs::dir_exists(stratum_path)) log_error("Stratum does not exist")

  execution_plan <-
    build_execution_plan(project_path) |>
    dplyr::filter(.data$stratum == stratum_name)

  run_execution_plan(execution_plan, silent)
  invisible(execution_plan)
}

#' Run a lamina adhoc by itself
#'
#' @param lamina_path Path to lamina
#' @param silent Suppress log output
#'
#' @return invisible data frame of execution plan
#' @export
#'
#' @examples
#' \dontrun{
#' adhoc_lamina("PATH/TO/LAMINA/FOLDER/")
#' }
#' @importFrom rlang .data
adhoc_lamina <- function(lamina_path, silent = FALSE) {
  lamina_name <- fs::path_file(lamina_path)
  project_path <-
    purrr::reduce(
      1:3,
      \(x, y) fs::path_dir(x),
      .init = lamina_path
    )


  execution_plan <-
    build_execution_plan(project_path) |>
    dplyr::filter(.data$lamina == lamina_name)

  run_execution_plan(execution_plan, silent)
  invisible(execution_plan)
}
