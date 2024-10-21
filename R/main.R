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
