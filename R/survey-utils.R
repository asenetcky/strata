scout_path <- function(path) {
  # check user input
  checkmate::assert_character(path)

  path <- fs::path(path)

  # check path type
  is_dir <- fs::is_dir(path)
  is_file <- rep(FALSE, length(path))

  # check if file
  if (!any(is_dir)) {
    is_file <- fs::is_file(path)
  }
  bad_paths <- NULL
  bad_paths <- path[!is_dir & !is_file]

  # if not dir or file abort
  if (!purrr::is_empty(bad_paths)) {
    msg <-
      paste(
        "Path must be an existing, accessible directory or a file",
        paste(bad_paths, collapse = ", ")
      )
    rlang::abort(msg)
  }

  invisible(path)
}
