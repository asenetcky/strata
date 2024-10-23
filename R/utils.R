clean_name <- function(name) {
  name |>
    stringr::str_trim() |>
    stringr::str_to_lower() |>
    stringr::str_replace_all("[^[:alnum:]]|\\s", "_")
}

check_pipeline <- function(pipeline_path) {
  #force to fs::path
  pipeline_path <- fs::path(pipeline_path)

  strata_issue <- FALSE
  # check if the pipeline exists
  if (!fs::dir_exists(pipeline_path)) {
    log_error(
      paste(
        fs::path_file(pipeline_path),
        "does not exist"
      )
    )
    strata_issue <- TRUE
  }

  # check if the pipeline has a modules folder
  # if (!fs::dir_exists(fs::path(pipeline_path, "modules"))) {
  #   log_error(
  #     paste(
  #       fs::path_file(pipeline_path),
  #       "does not have a modules folder"
  #     )
  #   )
  #   strata_issue <- TRUE
  # }
  # gather the intel on the project
  # read the .tomls, do they match up?
  !strata_issue
}
