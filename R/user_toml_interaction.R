survey_tomls <-  function(project_path) {
  find_tomls(project_path)
}

view_toml <- function(toml_path) {
  snapshot_toml(
    fs::path(toml_path)
  )
}

edit_toml <- function(original_toml_path, new_toml_dataframe) {
  rewrite_from_dataframe(new_toml_dataframe, original_toml_path)
  invisible(original_toml_path)
}
