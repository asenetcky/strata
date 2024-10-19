build_pipeline <- function(pipeline_name, path = ".") {

  # Clean file name
  clean_name <-
    pipeline_name |>
    stringr::str_trim() |>
    stringr::str_to_lower() |>
    stringr::str_replace_all("[^[:alnum:]]|\\s", "_")

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

}
