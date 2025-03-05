# check user input in `adhoc()`
adhoc_check <- function(name, prompt = TRUE, project_path = NULL) {
  # check user input
  checkmate::assert_character(name)
  checkmate::assert_logical(prompt)

  # if no path use working directory
  if (is.null(project_path)) {
    project_path <- fs::path_wd()
    rlang::inform(
      glue::glue(
        "Setting project path to working directory: '{project_path}'"
      )
    )
  }

  # check path, check project and if good return project path
  project_path |>
    scout_path() |>
    scout_project() |>
    invisible()
}


# return parts of execution plan that exactly match
# user provided stratum/lamina name
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
    dplyr::distinct(stratum)

  lamina_matches <-
    execution_plan |>
    dplyr::filter(
      .data$lamina == name
    ) |>
    dplyr::distinct(stratum, lamina)

  dplyr::bind_rows(stratum_matches, lamina_matches) |>
    dplyr::distinct()
}


# provide user with console choices in case of multiple exact matches
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
