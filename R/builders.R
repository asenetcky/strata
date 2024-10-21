#' Add a pipeline skeleton to your project space
#'
#' @param pipeline_name A string that is the name of your pipeline
#' @param path a path to where you want to drop your pipeline
#'
#' @return invisibly returns fs::path to pipeline
#' @export
#'
#' @examples
#' build_pipeline("my_pipeline_name", "PATH/TO/PROJECT/FOLDER/")
build_pipeline <- function(pipeline_name, path = ".", order) {

  # Clean file name
  clean_name <- clean_name(pipeline_name)

  # Create paths for project and pipeline
  project_folder <- fs::path(path)
  pipelines_folder <- fs::path(project_folder, "pipelines")
  target_pipeline <- fs::path(pipelines_folder, clean_name)
  target_modules <- fs::path(target_pipeline, "modules")

  # Create folders
  fs::dir_create(target_modules, recurse = TRUE)

  #add a subfunction for creating main.R
  fs::file_create(fs::path(project_folder, "main.R"))

  # Create .pipeline.toml
  initial_pipeline_toml(
    path = pipelines_folder,
    name = clean_name,
    order = 1 #cant always assume this, need some logic
  )

  base::invisible(target_pipeline)
}


build_module <- function(module_name, pipeline_path, order, skip_if_fail = FALSE ) {
  # check pipeline structure -  something like check_pipeline()
  # clean name
  # build path
  # implement some kind of trycatch deal to skip if fails
  # create the .toml file
  # implement some kind of ordering of the module, and then later on
  # do the same thing for submodules, but not here
}


check_pipeline <- function(pipeline_path) {
  #force to fs::path
  pipeline_path <- fs::path(pipeline_path)

  strata_issue <- FALSE
  # check if the pipeline exists
  if (!fs::dir_exists(pipeline_path)) {
    log_error(
      paste(
        basename(pipeline_path),
        "does not exist i"
      )
    )
    strata_issue <- TRUE
  }

  # check if the pipeline has a modules folder
  if (!fs::dir_exists(fs::path(pipeline_path, "modules"))) {
    log_error(
      paste(
        basename(pipeline_path),
        "does not have a modules folder"
      )
    )
    strata_issue <- TRUE
  }

  # gather the intel on the project
  # read the .tomls, do they match up?


}


build_main <- function(project_path) {
 project_path <- fs::path(project_path)
 is_main <- fs::file_exists(fs::path(project_path, "main.R"))
  if (!is_main) {
    fs::file_create(fs::path(project_path, "main.R"))
  }
}

