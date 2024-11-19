#' Find all toml files in a project
#'
#' @inheritParams main
#'
#' @return an fs_path object of all toml files.
#' @export
#'
#' @examples
#' tmp <- fs::dir_create(fs::file_temp())
#' strata::build_quick_strata_project(tmp, 2, 3)
#' survey_tomls(tmp)
#' fs::dir_delete(tmp)
survey_tomls <- function(project_path) {
  find_tomls(project_path)
}

#' View the contents of a toml file as a dataframe
#'
#' @param toml_path Path to the toml file
#'
#' @return a dataframe of the toml file contents.
#' @export
#'
#' @examples
#' tmp <- fs::dir_create(fs::file_temp())
#' strata::build_quick_strata_project(tmp, 2, 3)
#' proj_tomls <- survey_tomls(tmp)
#' purrr::map(proj_tomls, view_toml)
#' fs::dir_delete(tmp)
view_toml <- function(toml_path) {
  snapshot_toml(fs::path(toml_path))
}

#' Edit a toml file by providing a dataframe replacement
#'
#' Users can use `edit_toml()` to edit a toml file (should they opt not to use a
#' text editor) by providing a dataframe of the desired contents. The function
#' will check the dataframe for validity and then rewrite the toml file using
#' the dataframe as a blueprint.
#'
#'
#' @param original_toml_path Path to the original toml file.
#' @param new_toml_dataframe Dataframe of the new toml file contents with the
#' following columns: `type`, `name`, `order`, `skip_if_fail`, `created`.
#'
#' @section `new_toml_dataframe`:
#' `edit_toml()` will check the dataframe for the following columns:
#' * `type`: The type of the toml file, a character that is  either "strata"
#' or "laminae"
#' * `name`: The character string that is the name of the stratum or lamina
#' * `order`: The numeric order of the stratum or lamina
#' * `skip_if_fail`: (if type == laminae) A logical indicating if the lamina
#' should be skipped if it fails
#' * `created`: A valid date that is the day the stratum or lamina was created
#'
#' Unexpected columns will be dropped, and `edit_toml()` will warn the user.
#' If there are any missing columns, `edit_toml()` will return an error, stop
#' and inform the user what is missing.
#'
#' If there are duplicates in the `order` than `strata` will rewrite the order
#' using its best guess.
#'
#' @section usage:
#' Users using this function will likely want to combine some of the other
#' helpers in `strata`. This may looks something like this:
#' * User runs [survey_tomls()] to find all the toml files in the project
#' * User runs [view_toml()] to view the contents of the toml file and saves
#' to an object, like `original_toml` or similiar
#' * User edits the `original_toml` object to their liking and saves as a
#' new object, like `new_toml`.
#' * User runs `edit_toml()` with the path to the original toml and
#' `new_toml` objects and can then use [view_toml()] to confirm the changes.
#'
#' @return invisible original toml file path to toml file
#' @export
#'
#' @examples
#' tmp <- fs::dir_create(fs::file_temp())
#' strata::build_quick_strata_project(tmp, 2, 3)
#' original_toml_path <- survey_tomls(tmp)[[1]]
#' original_toml <- view_toml(original_toml_path)
#' original_toml
#' new_toml <- original_toml |>
#'   dplyr::mutate(
#'     created = as.Date("2021-01-01")
#'   )
#' new_toml_path <- edit_toml(original_toml_path, new_toml)
#' view_toml(new_toml_path)
#' fs::dir_delete(tmp)
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
