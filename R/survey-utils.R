scout_path <- function(path) {
  # check user input
  checkmate::assert_character(path)

  project_path <- fs::path(project_path)

  # check if project_path exists
  checkmate::assert_true(fs::dir_exists(project_path))
}
