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
  if (length(bad_paths) > 0) {
    msg <-
      glue::glue(
        "Path must be an accessible directory or a file:
        ",
        glue::glue_collapse(
          glue::single_quote(bad_paths),
          sep = ", ",
          last = ""
        )
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

  if (strata_exist) {
    has_strata <-
      dplyr::if_else(
        fs::file_exists(
          fs::path(strata_folder, ".strata.toml")
        ),
        TRUE,
        FALSE
      )
  }

  if (has_strata) {
    laminae_tomls <-
      fs::dir_ls(
        strata_folder,
        all = TRUE,
        recurse = TRUE,
        glob = ".*laminae.toml"
      )
    has_laminae <- length(laminae_tomls) > 0
  }

  if (!any(has_strata, has_laminae)) {
    msg <- glue::glue("'{path}' is not a strata project
                      has strata: {has_strata}
                      has laminae: {has_laminae}")
    rlang::abort(msg)
  }

  invisible(path)
}
