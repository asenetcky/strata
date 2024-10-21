#' Add a pipeline skeleton to your project space
#'
#' @param pipeline_name A string that is the name of your pipeline
#' @param path a path to where you want to drop your pipeline
#' @param order the order of the pipeline
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

  # Create .pipelines.toml
  initial_pipeline_toml(
    path = pipelines_folder,
    name = clean_name,
    order = 1 #cant always assume this, need some logic
  )

  base::invisible(target_pipeline)
}


build_module <- function(module_name, pipeline_path, order, skip_if_fail = FALSE ) {
  #grab the strata structure
  module_name <- clean_name(module_name)
  pipeline_path <- fs::path(pipeline_path)

  checkmate::assert_true(check_pipeline(pipeline_path))

  modules_path <- fs::path(pipeline_path, "modules")
  modules_toml <- fs::path(modules_path, ".modules.toml")


  #create the new module's folder
  new_module_path <- fs::path(pipeline_path, "modules", module_name)
  fs::dir_create(new_module_path)

  # .module.toml if it doesn't exist
  if (!fs::file_exists(modules_toml)) {
    initial_module_toml(modules_path)
  }

 # read the .toml file
  current_modules <-
    RcppTOML::tomlparse(modules_toml) |>
    purrr::pluck("modules")


  # update .modules.toml
  if (!module_name %in% current_modules) {
    cat(
      paste0(
        module_name, " = { created = ", lubridate::today(),
        ", order = ", order,
        ", skip_if_fail = ", skip_if_fail,
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
        fs::path_file(pipeline_path, "modules")
      )
    )
  }




  # check pipeline structure -  something like check_pipeline()
  # clean name
  # build path
  # implement some kind of trycatch deal to skip if fails
  # create the .toml file
  # implement some kind of ordering of the module, and then later on
  # do the same thing for submodules, but not here


}






build_main <- function(project_path) {
 project_path <- fs::path(project_path)
 is_main <- fs::file_exists(fs::path(project_path, "main.R"))
  if (!is_main) {
    fs::file_create(fs::path(project_path, "main.R"))
  }
}

