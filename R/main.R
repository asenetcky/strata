# pipeline_toml <-
#   RcppTOML::parseToml(fs::path("./pipelines/.pipelines.toml"))
#
# module_tomls <-
#   purrr::map(
#     names(pipeline_toml$pipelines),
#     \(pipe) {
#       RcppTOML::parseToml(
#         fs::path(
#           paste0("./pipelines/", pipe, "/modules/.modules.toml")
#         )
#       )
#     }
#   )

# dplyr::as_tibble(pipeline_toml$pipelines) |>
#   tidyr::pivot_longer(everything(),
#                       names_to = "pipeline",
#                       values_to = "info")

find_pipelines <- function(path = ".") {
  where_is_main <- fs::path_abs(path)
  toml_path <- fs::path(where_is_main, "pipelines/.pipelines.toml")

  toml_path |>
    build_paths()
}

find_modules <- function(path = ".") {
  #TODO enforce the assumumption it's being fed a pipeline
  toml_path <- fs::path(path, ".modules.toml")

  toml_path |>
    build_paths() |>
    fs::dir_ls(glob = "*.R")
  #this prints out submodule paths
}

#' @importFrom rlang .data
build_paths <- function(toml_path) {
  toml_path <- fs::path(toml_path)
  toml <- snapshot_toml(toml_path)

  target_path <- fs::path_dir(toml_path)

  toml |>
    dplyr::arrange(.data$order) |>
    dplyr::mutate(
      paths = fs::path(
        target_path,
        .data$name
      )
    ) |>
    dplyr::pull(.data$paths)

}

plan_runtime <- function() {
  find_pipelines() |>
    find_modules()
}

#testing
main <- function(path= ".") {
  path <- fs::path(path)


  execution_plan <-
    find_pipelines(path) |>
    find_modules() |>
    plan_messages()


  execution_plan$path |>
    purrr::map(
      \(submodule) source(submodule)
    )
  #replace source with one of the wrappers


}

plan_messages <- function(path) {
  path <- fs::path(path)

  pipeline_name <-
    fs::path_dir(path)

  script_name <-
    fs::path_file(path) |>
    stringr::str_remove("\\.R")

  module_name <-
    fs::path_file(
      fs::path_dir(path)
    )

  # dplyr::lst(
  #   "path" = path,
  #   "script_name" = script_name,
  #   "module_name" = module_name
  # )

  dplyr::tibble(
    "path" = path,
    "script_name" = script_name,
    "module_name" = module_name,
    "pipeline_name" = pipeline_name
  )
}
