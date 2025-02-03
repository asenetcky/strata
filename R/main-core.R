#' Execute entire strata project
#'
#' @description `main()` will read the `.toml` files inside the `project_path`
#' and begin sourcing the `strata` and `laminae` in the order specified by the
#' user, with or without logging messages.
#'
#' When a strata project is created `main.R` is added to the project root. This
#' script houses `main()`, and this file is the entry point to the project and
#' should be the target for automation. However, `main()` can be called from
#' anywhere, and users can opt to not use `main.R` at all.
#'
#' @section .toml files:
#'
#'   There are two types of `.toml` files that `main()` will read:
#' * `.strata.toml` - a singular file inside the `<project_path>/strata` folder
#' * `.laminae.toml` - a file inside each `<project_path>/strata/<stratum_name>`
#'   folder
#'
#'   These files are created by the `strata` functions and are used to determine
#'   primarily the order of execution for the strata and laminae.  Anything not
#'   referenced by a .toml will be ignored by `main()` and other functions such
#'   as [survey_strata()], [adhoc_stratum()], and [adhoc_lamina()]. Users can
#'   safely add other folders and files in the project root, and even within the
#'   subfolders and they will be ignored, unless users have code known by a
#'   `.toml` that references them.
#'
#'   Users can use the functions [survey_tomls()] and [view_toml())] to find and
#'   view the `.toml` files in their project.
#'
#' @param project_path A path to strata project folder.
#' @param silent Suppress log messages? If `FALSE` (the default), log messages
#'   will be printed to the console. If `TRUE`, log messages will be suppressed.
#'
#' @return invisible execution plan.
#' @export
#'
#' @examples
#' tmp <- fs::dir_create(fs::file_temp())
#' result <- strata::build_quick_strata_project(tmp, 1, 1)
#' main(tmp)
#' fs::dir_delete(tmp)
main <- function(project_path, silent = FALSE) {
  execution_plan <-
    project_path |>
    scout_path() |>
    scout_project() |>
    build_execution_plan()

  run_execution_plan(execution_plan, silent)

  invisible(execution_plan)
}
