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
build_pipeline <- function(pipeline_name, path= ".") {

  # Clean file name
  clean_name <- clean_name(pipeline_name)

  # Create paths for project and pipeline
  project_folder <- fs::path(path)
  pipelines_folder <- fs::path(project_folder, "pipelines")
  target_pipeline <- fs::path(pipelines_folder, clean_name)
  target_modules <- fs::path(target_pipeline, "modules")

  # Create folders
  fs::dir_create(target_modules, recurse = TRUE)

  # is main.R
  is_main <- fs::file_exists(fs::path(project_folder, "main.R"))

  # here is where I would use a sub-function to create the main.R file
  #for now this palceholder will do
  if (!is_main) {
    fs::file_create(fs::path(project_folder, "main.R"))
  }

  # Create pipeline_start
  # here I would use some sort of sub function to create
  # this standard file, this place holder will do
  pipeline_start <- fs::path(target_pipeline, "pipeline_start.R")
  fs::file_create(pipeline_start)

  # Create .pipeline.toml
  pipeline_toml <- fs::path(target_pipeline, ".pipeline.toml")
  fs::file_create(pipeline_toml)
  # another place for a sub function to write out a standard toml

  invisible(target_pipeline)
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
