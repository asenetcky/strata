scout_path <- function(path) {
  # check user input
  checkmate::assert_character(path)

  path <- fs::path(path)

  if (fs::is_dir(path)) {
    # check if path exists
    checkmate::assert_true(fs::dir_exists(path))
  }

 if (fs::is_file(path)) {
    # check if path exists
    checkmate::assert_true(fs::file_exists(path))
 }

  invisible(path)
}
