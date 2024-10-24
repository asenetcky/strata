find_pipelines <- function(path = ".") {
  where_is_main <- fs::path_abs(path)
  toml_path <- fs::path(where_is_main, "pipelines/.pipelines.toml")

  toml_path |>
    build_paths()
}

find_modules <- function(path = ".") {
  toml_path <- fs::path(path, ".modules.toml")

  toml_path |>
    build_paths() |>
    fs::dir_ls(glob = "*.R")
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

main <- function(path = NULL) {
  if (is.null(path)) stop("main() has no path")

  path <- fs::path(path)

  execution_plan <-
    build_execution_plan(path)

  run_execution_plan(execution_plan)

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
    dplyr::select(-"pipeline")

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
    dplyr::select(-"pipeline")

  paths <-
    plan |>
      list_to_tibble("path")

  paths |>
    dplyr::bind_cols(script_names) |>
    dplyr::bind_cols(module_names) |>
    dplyr::mutate(
      pipeline = fs::path_file(.data$pipeline)
    )

}

list_to_tibble <- function(list, name) {
  list |>
    purrr::imap(
      \(x,idx) {
        x |>
        dplyr::as_tibble() |>
          dplyr::mutate(pipeline = idx) |>
          dplyr::rename({{ name }} := .data$value)
      }
    ) |>
    purrr::list_rbind()
}
