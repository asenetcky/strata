#' Add a pipeline skeleton to your project space
#'
#' @param stratum_name A string that is the name of your stratum
#' @param path a path to where you want to drop your stratum
#' @param order the order of the stratum
#'
#' @return invisibly returns fs::path to stratum
#' @export
#'
#' @examples
#' build_stratum("my_stratum_name", "PATH/TO/PROJECT/FOLDER/")
build_stratum <- function(stratum_name, path = ".", order = 1) {

  #what if we dug into strata name more, pipeline becomes stratum?
  # module becomes lamina? flows?

  # Clean file name
  stratum_name <- clean_name(stratum_name)

  # Create paths for project and stratum
  project_folder <- fs::path(path)
  strata_folder <- fs::path(project_folder, "strata")
  target_stratum <- fs::path(strata_folder, stratum_name)
  strata_toml <- fs::path(strata_folder, ".strata.toml")

  # Create folders
  fs::dir_create(target_pipeline, recurse = TRUE)

  #add a subfunction for creating main.R
  fs::file_create(fs::path(project_folder, "main.R"))

  # .pipelines.toml if it doesn't exist
  first_pipeline_setup <- !fs::file_exists(pipelines_toml)

  # Create .pipelines.toml
  if (first_pipeline_setup) {
    initial_pipeline_toml(
      path = pipelines_folder,
      name = pipeline_name,
      order = order #cant always assume this, need some logic
    )
  }


  # read the .toml file
  toml_snapshot <- snapshot_toml(pipelines_toml)

  if (!first_pipeline_setup) {
     current_pipelines <-
      toml_snapshot |>
      dplyr::pull("name")

    # update .pipelines.toml
     if (!pipeline_name %in% current_pipelines) {
      cat(
        paste0(
          pipeline_name, " = { created = ", lubridate::today(),
          ", order = ", order,
          " }\n"
        ),
        file = pipelines_toml,
        append = TRUE
      )

       #trust but verify
       toml_snapshot <- snapshot_toml(pipelines_toml)

       sorted_toml <-
         manage_toml_order(toml_snapshot)

       if (!identical(sorted_toml, toml_snapshot)) {
         rewrite_from_dataframe(sorted_toml, pipelines_toml)
       }

       base::invisible(target_pipeline)

    } else {
      log_error(
        paste(
          pipeline_name,
          "already exists in",
          fs::path(pipelines_folder)
        )
      )

    }
  }
  invisible(target_pipeline)
}


build_module <- function(module_name, pipeline_path, order = 1, skip_if_fail = FALSE ) {
  #grab the strata structure
  module_name <- clean_name(module_name)
  pipeline_path <- fs::path(pipeline_path)

  checkmate::assert_true(check_pipeline(pipeline_path))

  modules_path <- pipeline_path
  modules_toml <- fs::path(modules_path, ".modules.toml")


  #create the new module's folder
  new_module_path <- fs::path(pipeline_path, module_name)
  fs::dir_create(new_module_path)

  # .module.toml if it doesn't exist
  if (!fs::file_exists(modules_toml)) {
    initial_module_toml(modules_path)
  }

  # read the .toml file
  toml_snapshot <- snapshot_toml(modules_toml)

  # read the .toml file

  if (!purrr::is_empty(toml_snapshot)) {
    current_modules <-
      toml_snapshot |>
      dplyr::pull("name")
  } else {
    current_modules <- ""
  }


  # update .modules.toml
  if (!module_name %in% current_modules) {
    cat(
      paste0(
        module_name, " = { created = ", lubridate::today(),
        ", order = ", order,
        ", skip_if_fail = ", stringr::str_to_lower(skip_if_fail),
        " }\n"
      ),
      file = modules_toml,
      append = TRUE
    )
  } else {
    log_error(
      paste(
        module_name,
        "already exists in",
        fs::path(pipeline_path, "modules")
      )
    )
  }

  #trust but verify
  toml_snapshot <- snapshot_toml(modules_toml)

  sorted_toml <-
    manage_toml_order(toml_snapshot)

  if (!identical(sorted_toml, toml_snapshot)) {
    rewrite_from_dataframe(sorted_toml, modules_toml)
  }


  base::invisible(new_module_path)
}


build_main <- function(project_path) {
 project_path <- fs::path(project_path)
 main_path <- fs::path(project_path, "main.R")
 is_main <- fs::file_exists(main_path)
  if (!is_main) {
    fs::file_create(main_path)
    cat(
      paste0("library(strata)\nstrata:::main(", project_path, ")\n"),
      file = main_path,
      append = TRUE
    )
  }
}


