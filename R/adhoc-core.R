#' Execute a single stratum ad hoc
#'
#' `adhoc_stratum()` will execute _only_ the stratum, its child
#' laminae and the code therein contained as specified by `stratum_path`
#' with or without log messages.
#'
#' @inheritParams main
#' @inheritParams build_lamina
#' @family adhoc
#'
#' @return invisible data frame of execution plan.
#' @export
#'
#' @examples
#' tmp <- fs::dir_create(fs::file_temp())
#' result <- strata::build_quick_strata_project(tmp, 1, 1)
#' adhoc_stratum(
#'   fs::path(tmp, "strata", "stratum_1"),
#' )
#' fs::dir_delete(tmp)
#' @importFrom rlang .data
adhoc_stratum <- function(stratum_path, silent = FALSE) {
  # check user input
  checkmate::assert_logical(silent)

  stratum_path <- scout_path(stratum_path)

  # get the stratum name
  stratum_name <- fs::path_file(stratum_path)

  # infer project path and then check
  project_path <-
    fs::path_dir(
      fs::path_dir(stratum_path)
    ) |>
    scout_project()

  # build project plan and then filter
  execution_plan <-
    build_execution_plan(project_path) |>
    dplyr::filter(.data$stratum == stratum_name)

  # execute
  run_execution_plan(execution_plan, silent)

  # return the execution plan
  invisible(execution_plan)
}

#' Execute a single lamina ad hoc
#'
#' `adhoc_lamina()` will execute _only_ the lamina and the code
#' therein contained as specified by `lamina_path`
#' with or without log messages.
#'
#' @inheritParams main
#' @inheritParams build_lamina
#' @param lamina_path Path to lamina.
#' @family adhoc
#'
#' @return invisible data frame of execution plan.
#' @export
#'
#' @examples
#' tmp <- fs::dir_create(fs::file_temp())
#' result <- strata::build_quick_strata_project(tmp, 1, 1)
#' adhoc_lamina(
#'   fs::path(tmp, "strata", "stratum_1", "s1_lamina_1"),
#' )
#' fs::dir_delete(tmp)
#' @importFrom rlang .data
adhoc_lamina <- function(lamina_path, silent = FALSE) {
  # global bindings
  path <- lamina_target <- NULL

  # check user input
  checkmate::assert_logical(silent)

  lamina_path <-
    scout_path(lamina_path) |>
    fs::path_expand()

  # get the lamina name
  lamina_name <- fs::path_file(lamina_path)

  # infer all the project paths and check
  project_path <-
    purrr::reduce(
      1:3,
      \(x, y) fs::path_dir(x),
      .init = lamina_path
    ) |>
    scout_project()

  # build execution plan for target lamina
  execution_plan <-
    build_execution_plan(project_path) |>
    dplyr::mutate(
      lamina_target = fs::path_has_parent(
        parent = lamina_path,
        path = path
      )
    ) |>
    dplyr::filter(lamina_target)

  run_execution_plan(execution_plan, silent)

  invisible(execution_plan)
}


#' Execute a single stratum or lamina ad hoc by its name
#'
#' In interactive sessions, `adhoc()` will execute the stratum or lamina that
#' matches the name provided by the user. If multiple matches are found, the
#' user will be prompted to choose which one to execute.  If no matches are
#' found, an error will be thrown. `project_path` will default to the current
#' working directory, unless a path is provided by the user.
#'
#' @inheritParams main
#' @param name Name of stratum or lamina.
#' @param prompt Prompt user for choice if multiple matches found?
#' Default is `TRUE`.
#'
#' @family adhoc
#'
#' @returns invisible data frame of execution plan for matched name.
#' @export
#'
#' @examples
#' \dontrun{
#' tmp <- fs::dir_create(fs::file_temp())
#' result <- strata::build_quick_strata_project(tmp, 3, 2)
#' adhoc("stratum_1")
#' fs::dir_delete(tmp)
#' }
adhoc <- function(name, prompt = TRUE, silent = FALSE, project_path = NULL) {
  # interactive only
  if (!rlang::is_interactive()) {
    rlang::abort("This function is for interactive sessions only")
  }

  # global bindings
  stratum <- lamina <- NULL

  # check user input
  project_path <- adhoc_check(name, prompt, project_path)

  # build standard execution plan
  execution_plan <- build_execution_plan(project_path)

  # exact match user input against standard execution plan
  distinct_matches <-
    adhoc_matches(name, execution_plan)

  # hand matches
  # if no match
  if (nrow(distinct_matches) == 0 | purrr::is_empty(distinct_matches)) {
    rlang::abort(
      glue::glue(
        "No matches found for '{name}' in '{project_path}'"
      )
    )
  }

  # if name matches both stratum and lamina or multiple lamina
  if (nrow(distinct_matches) > 1) {
    rlang::inform(
      glue::glue(
        "Multiple matches found for '{name}' in '{project_path}'"
      )
    )

    matches <-
      adhoc_freewill(
        distinct_matches,
        prompt = prompt
      ) |>
      dplyr::inner_join(
        execution_plan,
        by = c("stratum", "lamina")
      )
  }

  # if only one match and lamina
  if (nrow(distinct_matches) == 1 && !is.na(distinct_matches$lamina)) {
    matches <-
      distinct_matches |>
      dplyr::inner_join(
        execution_plan,
        by = c("stratum", "lamina")
      )
  }

  # if only one match and it's a stratum
  if (nrow(distinct_matches) == 1 && is.na(distinct_matches$lamina)) {
    matches <-
      execution_plan |>
      dplyr::filter(stratum == distinct_matches$stratum)
  }

  # execute matches in execution plan
  run_execution_plan(execution_plan = matches, silent = silent)

  invisible(matches)
}
