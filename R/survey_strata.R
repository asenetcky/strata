#' Survey the layout and execution order of your project
#'
#' @description
#' `survey_strata()` will examine the .tomls in `project_path` provided and
#' return a dataframe with the following information about the project:
#'
#' * `stratum_name`: the name of the stratum
#' * `lamina_name`: the name of the lamina
#' * `execution_order`: the order in which the stratum-lamina-code combination
#' will be executed
#' * `script_name`: the name of the script to be executed
#' * `script_path`: the path to the script
#'
#' This is based on the contents of the .toml files, everything else is
#' "invisible" inside the strata project.
#'
#' @inheritParams main
#'
#' @return dataframe housing the layout of your project based on the .tomls.
#' @export
#'
#' @examples
#' tmp <- fs::dir_create(fs::file_temp())
#' build_quick_strata_project(tmp, 2, 2)
#' survey_strata(tmp)
#' fs::dir_delete(tmp)
survey_strata <- function(project_path) {
  stratum <- lamina <- path <- order <- script <- created <- NULL
  skip_if_fail <- execution_order <- script_path <- stratum_name <- NULL

  project_path <- fs::path(project_path)

  build_execution_plan(project_path) |>
    dplyr::rename(
      stratum_name = stratum,
      lamina_name = lamina,
      execution_order = order,
      script_name = script,
      script_path = path
    ) |>
    dplyr::relocate(
      c(skip_if_fail, created),
      .after = script_path
    ) |>
    dplyr::relocate(
      execution_order,
      .before = stratum_name
    )
}
