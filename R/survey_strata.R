#' Survey the layout and execution order of your project
#'
#' @param project_path path to your project folder
#'
#' @return data frame of the layout of your project based on the .tomls
#' @export
#'
#' @examples
#' \dontrun{
#' survey_strata("PATH/TO/PROJECT/FOLDER/")
#' }
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
