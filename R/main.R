#' Entry point and automation target for your strata project
#'
#' @param project_path A path to strata project folder
#' @param silent Suppress log messages? If `FALSE` (the default), log messages
#' will be printed to the console. If `TRUE`, log messages will be suppressed.
#'
#' @return invisible execution plan
#' @export
#'
#' @examples
#' \dontrun{
#' main("/PATH/TO/PROJECT/FOLDER")
#' }
main <- function(project_path, silent = FALSE) {
  project_path <- fs::path(project_path)

  execution_plan <-
    build_execution_plan(project_path)

  run_execution_plan(execution_plan, silent)

  invisible(execution_plan)
}
