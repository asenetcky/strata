clean_name <- function(name) {
  name |>
    stringr::str_trim() |>
    stringr::str_to_lower() |>
    stringr::str_replace_all("[^[:alnum:]]|\\s", "_")
}

check_stratum <- function(stratum_path) {
  #force to fs::path
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

  # check if the stratum has a modules folder
  # if (!fs::dir_exists(fs::path(stratum_path, "modules"))) {
  #   log_error(
  #     paste(
  #       fs::path_file(stratum_path),
  #       "does not have a modules folder"
  #     )
  #   )
  #   strata_issue <- TRUE
  # }
  # gather the intel on the project
  # read the .tomls, do they match up?
  !strata_issue
}
