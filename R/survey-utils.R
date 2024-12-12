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
        paste(bad_paths, collapse = ", ")
      )
    rlang::abort(msg)
  }

  invisible(path)
}



# check if strataproject
