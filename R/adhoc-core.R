#' Execute a single stratum ad hoc
#'
#' `adhoc_stratum()` will execute _only_ the stratum, its child
#' laminae and the code therein contained as specified by `stratum_path`
#' with or without log messages.
#'
#' @inheritParams main
#' @inheritParams build_lamina
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

  # infer all the project paths
  project_path <-
    purrr::reduce(
      1:3,
      \(x, y) fs::path_dir(x),
      .init = lamina_path
    )

  # check all project paths


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


adhoc <- function(name, prompt = TRUE, silent = FALSE, project_path = NULL) {
  # interactive only
  if (!interactive()) {
    rlang::abort("This function is for interactive only")
  }

  # global bindings
  stratum <- lamina <- NULL

  project_path <- adhoc_check(name, prompt, project_path)
  execution_plan <- build_execution_plan(project_path)

  distinct_matches <-
    adhoc_matches(name, execution_plan)

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

    run_execution_plan(execution_plan = matches, silent = silent)
  }

  # if only one match
  if (nrow(distinct_matches) == 1) {
    matches <-
      distinct_matches |>
      dplyr::inner_join(
        execution_plan,
        by = c("stratum", "lamina")
      )

    run_execution_plan(execution_plan = matches, silent = silent)
  }

  invisible(matches)
}

adhoc_check <- function(name, prompt = TRUE, project_path = NULL) {
  # if no path use working directory
  if (is.null(project_path)) {
    project_path <- fs::path_wd()
    rlang::inform(
      glue::glue(
        "Setting project path to working directory: '{project_path}'"
      )
    )
  }

  # check user input
  checkmate::assert_character(name)
  checkmate::assert_logical(prompt)

  project_path <-
    project_path |>
    scout_path() |>
    scout_project()

  invisible(project_path)
}

#' @importFrom rlang .data
adhoc_matches <- function(name, execution_plan) {
  # global bindings
  stratum <- lamina <- NULL

  # grab matches
  stratum_matches <-
    execution_plan |>
    dplyr::filter(
      .data$stratum == name
    ) |>
    dplyr::distinct(stratum, lamina)


  lamina_matches <-
    execution_plan |>
    dplyr::filter(
      .data$lamina == name
    ) |>
    dplyr::distinct(stratum, lamina)


  dplyr::bind_rows(stratum_matches, lamina_matches) |>
    dplyr::distinct()
}

adhoc_freewill <- function(distinct_matches, prompt) {
  # global bindings
  stratum <- lamina <- NULL

  choices <-
    distinct_matches |>
    dplyr::mutate(
      choice = paste(stratum, lamina),
      id = dplyr::row_number(),
      .keep = "none"
    )

  if (prompt) {
    choice <- utils::menu(choices = choices$choice)
  } else {
    choice <- 1
    rlang::inform(
      glue::glue(
        "Choosing first match: '{choices$choice[1]}'"
      )
    )
  }

  distinct_matches[choice, ]
}
