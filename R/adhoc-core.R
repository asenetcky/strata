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
  stratum_name <- fs::path_file(stratum_path)

  project_path <-
    fs::path_dir(
      fs::path_dir(stratum_path)
    )

  execution_plan <-
    build_execution_plan(project_path) |>
    dplyr::filter(.data$stratum == stratum_name)

  run_execution_plan(execution_plan, silent)

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
  # check user input
  checkmate::assert_logical(silent)
  lamina_path <- scout_path(lamina_path)

  # get the lamina name
  lamina_name <- fs::path_file(lamina_path)

  # grab all the project paths
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


adhoc <- function(name, prompt = TRUE, silent = FALSE, project_path = NULL) {
  # interactive only
  if (!interactive()) {
    rlang::abort("This function is for interactive only")
  }

  project_path <- adhoc_check(name, prompt, project_path)

  matches <-
    adhoc_matches(name, project_path) |>
    purrr::discard(\(x) nrow(x) == 0)

  # if no match
  if (length(matches) == 0) {
    rlang::abort(
      glue::glue(
        "No matches found for '{name}' in '{project_path}'"
      )
    )
  }

  # if name matches both stratum and lamina
  if (length(matches) > 1) {

    rlang::inform(
      glue::glue(
        "Multiple matches found for '{name}' in '{project_path}'
        please select proper match:"
      )
    )

    choice <-
      switch(
        utils::menu(
          choices = c(
            glue::glue("Stratum: {name}"),
            glue::glue("Lamina: {name}")
          )
        ) + 1,
        cat("Nothing done\n"),
        "stratum_matches",
        "lamina_matches"
      )

    matches <-
      matches |>
      purrr::pluck(choice)


  }

  # if only one match
  if (length(matches) == 1) {
    matches <-
      matches |>
      purrr::pluck(1)

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
adhoc_matches <- function(name, project_path) {
  # grab execution plan
  plan <- build_execution_plan(project_path)

  # grab matches
  stratum_matches <-
    plan |>
    dplyr::filter(
      .data$stratum == name
    )

  lamina_matches <-
    plan |>
    dplyr::filter(
      .data$lamina == name
    )

  # lst matches together
  dplyr::lst(stratum_matches, lamina_matches)
}
