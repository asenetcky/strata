#' Find all toml files in a project
#'
#' @inheritParams main
#'
#' @return an fs_path of all toml files
#' @export
#'
#' @examples
#' \dontrun{
#' find_tomls("PATH/TO/PROJECT/FOLDER/")
#' }
survey_tomls <- function(project_path) {
  # since this is a wrapper i'll likely add more user-facing functionality
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
  # since this is a wrapper i'll likely add more user-facing functionality
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
  new_toml_dataframe <-
    check_toml_dataframe(new_toml_dataframe)

  rewrite_from_dataframe(new_toml_dataframe, original_toml_path)
  invisible(original_toml_path)
}


check_toml_dataframe <- function(toml_dataframe) {
  expected_columns <-
    c("type", "name", "order", "skip_if_fail", "created")

  toml_type <- unique(toml_dataframe$type)
  if (toml_type == "strata") {
    expected_columns <- c("type", "name", "order", "created")
  }

  non_valid_names <-
    !names(toml_dataframe) %in% expected_columns

  if (any(non_valid_names)) {
    bad_names <- names(toml_dataframe)[which(non_valid_names)]
    log_message(
      paste(
        "The following columns are not valid and will be dropped:",
        paste(bad_names, collapse = ", ")
      )
    )
  }

  missing_names <-
    expected_columns[!expected_columns %in% names(toml_dataframe)]

  if (length(missing_names) > 0) {
    stop(
      paste(
        "The following columns are missing:",
        paste(missing_names, collapse = ", ")
      )
    )
  }

  toml_dataframe <-
    toml_dataframe |>
    dplyr::select(dplyr::any_of(expected_columns)) |>
    manage_toml_order()

  checkmate::assert_character(toml_dataframe$type)
  checkmate::assert_character(toml_dataframe$name)
  checkmate::assert_integerish(toml_dataframe$order)

  if ("skip_if_fail" %in% names(toml_dataframe)) {
    checkmate::assert_logical(toml_dataframe$skip_if_fail)
  }

  checkmate::assert_date(toml_dataframe$created)

  toml_dataframe
}
