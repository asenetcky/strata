scout_path <- function(path) {
  # check user input
  checkmate::assert_character(path)

  path <- fs::path(path)

  # check path type
  is_dir <- fs::is_dir(path)
  is_file <- rep(FALSE, length(path))

  # check if file
  if (any(!is_dir)) {
    is_file <- fs::is_file(path)
  }
  bad_paths <- path[!is_dir & !is_file]

  # if not dir or file abort
  if (length(bad_paths) > 0 ) {
    msg <-
      glue::glue(
        "Path must be an accessible directory or a file:
        ",
        paste(paste0("'",bad_paths, "'"), collapse = ", ")
      )
    rlang::abort(msg)
  }

  invisible(path)
}


scout_project <- function(path) {
  # assumptions
  has_strata <- FALSE
  has_laminae <- FALSE

  # check path input
  path <- scout_path(path)

  # check if path is a strata project
  strata_folder <- fs::path(path, "strata")
  strata_exist <- fs::dir_exists(strata_folder)

  # check if tomls exists
  tomls <- find_tomls(path)

  if (!purrr::is_empty(tomls)) {
    has_strata_toml <-
      tomls |>
      fs::path_file() |>
      stringr::str_detect(stringr::fixed(".strata.toml")) |>
      any()

    has_laminae <-
      tomls |>
      fs::path_file() |>
      stringr::str_detect(stringr::fixed(".laminae.toml")) |>
      any()

    has_strata <- all(has_strata_toml, has_laminae_toml)
  }

  if (!any(has_strata, has_laminae)) {
    msg <- glue::glue("'{path}' is not a strata project")
    rlang::abort(msg)
  }

  invisible(path)
}
