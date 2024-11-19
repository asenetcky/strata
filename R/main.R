#' Execute entire strata project
#'
#' @description
#' `main()` will read the `.toml` files inside the `project_path` and begin
#' sourcing the `strata` and `laminae` in the order specified by the user,
#' with or without logging messages.
#'
#' When a strata project is created `main.R` is added to the project root.
#' This script houses `main()`, and this file is the entry point to the project
#' and should be the target for automation. However, `main()` can be called
#' from anywhere, and users can opt to not use `main.R` at all.
#'
#' @param project_path A path to strata project folder
#' @param silent Suppress log messages? If `FALSE` (the default), log messages
#' will be printed to the console. If `TRUE`, log messages will be suppressed.
#'
#' @return invisible execution plan
#' @export
#'
#' @examples
#' tmp <- fs::dir_create(fs::file_temp())
#' result <- strata::build_quick_strata_project(tmp, 1, 1)
#' main(tmp)
#' fs::dir_delete(tmp)
main <- function(project_path, silent = FALSE) {
  project_path <- fs::path(project_path)

  execution_plan <-
    build_execution_plan(project_path)

  run_execution_plan(execution_plan, silent)

  invisible(execution_plan)
}
