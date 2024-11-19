# TODO change path to projet_path in build_stratum
# TODO setup project path to be inherited by all the functions
# TODO describe default values in params
# TODO setup up order to be inheried, describe default value

#' Add a stratum to the project space
#'
#' @param stratum_name Name of your stratum
#' @param path A path to where you want to drop your stratum
#' @param order The order of the stratum
#'
#' @return invisibly returns fs::path to stratum
#' @export
#'
#' @examples
#' \dontrun{
#' build_stratum("my_stratum_name", "PATH/TO/PROJECT/FOLDER/")
#' }
build_stratum <- function(stratum_name, path = ".", order = 1) {
  # Clean file name
  stratum_name <- clean_name(stratum_name)

  # Create paths for project and stratum
  project_folder <- fs::path(path)
  strata_folder <- fs::path(project_folder, "strata")
  target_stratum <- fs::path(strata_folder, stratum_name)
  strata_toml <- fs::path(strata_folder, ".strata.toml")

  # Create folders
  fs::dir_create(target_stratum, recurse = TRUE)

  # add a subfunction for creating main.R
  build_main(project_folder)

  # .strata.toml if it doesn't exist
  first_stratum_setup <- !fs::file_exists(strata_toml)

  # Create .strata.toml
  if (first_stratum_setup) {
    initial_stratum_toml(
      path = strata_folder,
      name = stratum_name,
      order = order
    )
  }

  # read the .toml file
  toml_snapshot <- snapshot_toml(strata_toml)

  if (!first_stratum_setup) {
    current_strata <-
      toml_snapshot |>
      dplyr::pull("name")

    # update .strata.toml
    if (!stratum_name %in% current_strata) {
      cat(
        paste0(
          stratum_name, " = { created = ", lubridate::today(),
          ", order = ", order,
          " }\n"
        ),
        file = strata_toml,
        append = TRUE
      )

      # trust but verify
      toml_snapshot <- snapshot_toml(strata_toml)

      sorted_toml <-
        manage_toml_order(toml_snapshot)

      if (!identical(sorted_toml, toml_snapshot)) {
        rewrite_from_dataframe(sorted_toml, strata_toml)
      }

      base::invisible(target_stratum)
    } else {
      log_error(
        paste(
          stratum_name,
          "already exists in",
          fs::path(strata_folder)
        )
      )
    }
  }
  invisible(target_stratum)
}


#' Add a lamina to the project space
#'
#' @param lamina_name Name of your Lamina
#' @param stratum_path Path to the parent stratum
#' @param order Execution order inside of stratum
#' @param skip_if_fail Skip this lamina if it fails
#'
#' @return invisibly returns fs::path to lamina
#' @export
#'
#' @examples
#' \dontrun{
#' build_lamina("my_lamina_name", "PATH/TO/STRATUM/FOLDER/")
#' }
build_lamina <- function(lamina_name, stratum_path, order = 1, skip_if_fail = FALSE) {
  # grab the strata structure
  lamina_name <- clean_name(lamina_name)
  stratum_path <- fs::path(stratum_path)

  checkmate::assert_true(fs::dir_exists(stratum_path))

  laminae_path <- stratum_path
  laminae_toml <- fs::path(laminae_path, ".laminae.toml")


  # create the new lamina's folder
  new_lamina_path <- fs::path(stratum_path, lamina_name)
  fs::dir_create(new_lamina_path)

  # .lamina.toml if it doesn't exist
  if (!fs::file_exists(laminae_toml)) {
    initial_lamina_toml(laminae_path)
  }

  # read the .toml file
  toml_snapshot <- snapshot_toml(laminae_toml)

  if (!purrr::is_empty(toml_snapshot)) {
    current_laminae <-
      toml_snapshot |>
      dplyr::pull("name")
  } else {
    current_laminae <- ""
  }

  # update .laminae.toml
  if (!lamina_name %in% current_laminae) {
    cat(
      paste0(
        lamina_name, " = { created = ", lubridate::today(),
        ", order = ", order,
        ", skip_if_fail = ", stringr::str_to_lower(skip_if_fail),
        " }\n"
      ),
      file = laminae_toml,
      append = TRUE
    )
  } else {
    log_error(
      paste(
        lamina_name,
        "already exists in",
        fs::path(stratum_path, "laminae")
      )
    )
  }

  # trust but verify
  toml_snapshot <- snapshot_toml(laminae_toml)

  sorted_toml <-
    manage_toml_order(toml_snapshot)

  if (!identical(sorted_toml, toml_snapshot)) {
    rewrite_from_dataframe(sorted_toml, laminae_toml)
  }

  base::invisible(new_lamina_path)
}


build_main <- function(project_path) {
  project_path <- fs::path(project_path)
  main_path <- fs::path(project_path, "main.R")
  is_main <- fs::file_exists(main_path)
  if (!is_main) {
    fs::file_create(main_path)
    cat(
      paste0("library(strata)\nstrata::main('", project_path, "')\n"),
      file = main_path,
      append = TRUE
    )
  }
}

clean_name <- function(name) {
  name |>
    stringr::str_trim() |>
    stringr::str_to_lower() |>
    stringr::str_replace_all("[^[:alnum:]]|\\s", "_") |>
    fs::path_sanitize()
}
