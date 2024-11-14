clean_name <- function(name) {
  name |>
    stringr::str_trim() |>
    stringr::str_to_lower() |>
    stringr::str_replace_all("[^[:alnum:]]|\\s", "_")
}

check_stratum <- function(stratum_path) {
  # force to fs::path
  stratum_path <- fs::path(stratum_path)

  strata_issue <- FALSE
  # check if the stratum exists
  if (!fs::dir_exists(stratum_path)) {
    log_error(
      paste(
        fs::path_file(stratum_path),
        "does not exist"
      )
    )
    strata_issue <- TRUE
  }

  # check if the stratum has a laminae folder
  # if (!fs::dir_exists(fs::path(stratum_path, "laminae"))) {
  #   log_error(
  #     paste(
  #       fs::path_file(stratum_path),
  #       "does not have a laminae folder"
  #     )
  #   )
  #   strata_issue <- TRUE
  # }
  # gather the intel on the project
  # read the .tomls, do they match up?
  !strata_issue
}

survey_strata <- function(project_path) {
  stratum <- lamina <- path <- order <- script <-  created <- NULL
  skip_if_fail <- execution_order <- script_path <- stratum_name <- NULL

  project_path <- fs::path(project_path)

  plan <-
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
