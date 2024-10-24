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

  tomls <-
    toml_path |>
    # purrr::set_names() |>
    purrr::map(
      \(toml) snapshot_toml(toml)
    )

  target_paths <- fs::path_dir(toml_path)

  purrr::map2(
    tomls,
    target_paths,
    \(x, idx) {
      x |>
        dplyr::arrange(.data$order) |>
        dplyr::mutate(
          paths = fs::path(
            idx,
            .data$name
          )
        ) |>
        dplyr::pull(.data$paths)
    }
  ) |>
  purrr::list_c()
}

#testing
main <- function(path= ".") {
  path <- fs::path(path)

#
#   execution_plan <-
#     build_execution_plan(path) |>
#
#   execution_plan$path |>
#     purrr::map(
#       \(submodule) source(submodule)
#     )
  #replace source with one of the wrappers

}

build_execution_plan <- function(path) {
  path <- fs::path(path)

  pipelines <- find_pipelines(path)
  pipeline_name <- fs::path_file(pipelines)


  #somehting like this? huh <- pipelines |> purrr::map(list)
  plan <-
    pipelines |>
    purrr::map(purrr::pluck) |>
    purrr::set_names() |>
    purrr::map(find_modules)

  module_names <-
    plan |>
    purrr::map(
        \(path) {
            fs::path_file(
              fs::path_dir(path)
            )
        }
      ) |>
    list_to_tibble("module_name") |>
    dplyr::select(-pipeline)

  script_names <-
    plan |>
    purrr::map(
      \(path) {
        path |>
          fs::path_file() |>
          fs::path_ext_remove()
      }
    ) |>
    list_to_tibble("script_name") |>
    dplyr::select(-pipeline)

  paths <-
    plan |>
      list_to_tibble("path")

  paths |>
    dplyr::bind_cols(script_names) |>
    dplyr::bind_cols(module_names) |>
    dplyr::mutate(
      pipeline = fs::path_file(pipeline)
    )

}

list_to_tibble <- function(list, name) {
  list |>
    purrr::imap(
      \(x,idx) {
        x |>
        dplyr::as_tibble() |>
          dplyr::mutate(pipeline = idx) |>
          dplyr::rename({{ name }} := value)
      }
    ) |>
    purrr::list_rbind()
}
