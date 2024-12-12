scout_path <- function(path) {
  # check user input
  checkmate::assert_character(path)

  path <- fs::path(path)

  # check path type
  is_dir <- fs::is_dir(path)

  is_file <- FALSE

  if (!is_dir) {
    is_file <- fs::is_file(path)
  }

  if (!is_dir && !is_file) {
    rlang::abort("Path must be an existing, accessible directory or a file")
  }

  invisible(path)
}

