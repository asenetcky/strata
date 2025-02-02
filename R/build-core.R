#' Add a stratum to the project space
#'
#' @inheritParams main
#' @param stratum_name Name of stratum
#' @param order Execution order, default is `1`
#'
#' @return invisibly returns fs::path to stratum
#' @export
#'
#' @examples
#' tmp <- fs::dir_create(fs::file_temp())
#' result <- build_stratum("my_stratum_name", tmp)
#' result
#' fs::dir_delete(tmp)
build_stratum <- function(stratum_name, project_path, order = 1) {
  # Clean file name
  stratum_name <- clean_name(stratum_name)

  # Create paths for project and stratum
  project_folder <- fs::path(project_path)
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
          stratum_name, " = { created = ", Sys.Date(),
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

      invisible(target_stratum)
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
#' @inheritParams build_stratum
#' @param lamina_name Name of lamina
#' @param stratum_path Path to stratum folder
#' @param skip_if_fail Skip this lamina if it fails, default is `FALSE`
#'
#' @return invisibly returns fs::path to lamina
#' @export
#'
#' @examples
#' tmp <- fs::dir_create(fs::file_temp())
#' result_stratum_path <- build_stratum("my_stratum_name", tmp)
#' result_lamina_path <- build_lamina("my_lamina_name", result_stratum_path)
#' result_lamina_path
#' fs::dir_delete(tmp)
build_lamina <- function(lamina_name, stratum_path, order = 1, skip_if_fail = FALSE) {
  # grab the strata structure
  lamina_name <- clean_name(lamina_name)
  stratum_path <- scout_path(stratum_path)

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
        lamina_name, " = { created = ", Sys.Date(),
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

  invisible(new_lamina_path)
}

# given a project path create the main.R file and add the strata::main call
build_main <- function(project_path) {
  project_path <-
    scout_path(project_path) |>
    fs::path_expand()

  main_path <- fs::path(project_path, "main.R")

  if (!fs::file_exists(main_path)) {
    fs::file_create(main_path)
    cat(
      paste0("library(strata)\nstrata::main('", project_path, "')\n"),
      file = main_path,
      append = TRUE
    )
  }
}

# given a string, clean it up for use
clean_name <- function(name) {
  clean_name <-
    name |>
    stringr::str_trim() |>
    stringr::str_to_lower() |>
    stringr::str_replace_all("[^[:alnum:]|-]|\\s", "_") |>
    fs::path_sanitize()

  purrr::walk2(
    name,
    clean_name,
    \(n, cn) {
      if (n != cn) {
        msg <- paste("cleaning: replacing", n, "with", cn)
        rlang::inform(msg)
      }
    }
  )

  clean_name
}
