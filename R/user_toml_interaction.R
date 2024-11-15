#' Find all toml files in a project
#'
#' @param project_path Path to the project
#'
#' @return an fs_path of all toml files
#' @export
#'
#' @examples
#' \dontrun{
#' find_tomls("PATH/TO/PROJECT/FOLDER/")
#' }
survey_tomls <-  function(project_path) {
  #since this is a wrapper i'll likely add more user-facing functionality
  find_tomls(project_path)
}

#' View the contents of a toml file as a dataframe
#'
#' @param toml_path Path to the toml file
#'
#' @return a dataframe of the toml file contents
#' @export
#'
#' @examples
#' \dontrun{
#' view_toml("PATH/TO/TOML/FILE.toml")
#' }
view_toml <- function(toml_path) {
  #since this is a wrapper i'll likely add more user-facing functionality
  snapshot_toml(fs::path(toml_path))
}

#' Edit a toml file by providing a dataframe of desired contents
#'
#' @param original_toml_path Path to the original toml file
#' @param new_toml_dataframe Dataframe of the new toml file contents
#'
#' @return invisible original toml file path to toml file
#' @export
#'
#' @examples
#' \dontrun{
#' edit_toml("PATH/TO/ORIGINAL/TOML/FILE.toml", new_toml_dataframe)
#' }
edit_toml <- function(original_toml_path, new_toml_dataframe) {
  #TODO add checks and guardrails
  rewrite_from_dataframe(new_toml_dataframe, original_toml_path)
  invisible(original_toml_path)
}
