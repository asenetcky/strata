#' Entry point into your strata project and automation target
#'
#' @param project_path A path to automation project folder
#'
#' @return invisible execution plan
#' @export
#'
#' @examples
#'\dontrun{
#' main("/PATH/TO/PROJECT/FOLDER")
#'}
main <- function(project_path = NULL) {
  if (is.null(project_path)) stop("main() has no path")

  project_path <- fs::path(project_path)

  execution_plan <-
    build_execution_plan(project_path)

  run_execution_plan(execution_plan)

  invisible(execution_plan)
}

find_strata <- function(project_path = NULL) {
  if (is.null(project_path)) stop("main() has no path")

  path <- fs::path(project_path)
  toml_path <- fs::path(path, "strata/.strata.toml")

  toml_path |>
    build_paths()
}

find_laminae <- function(path = ".") {
  toml_path <- fs::path(path, ".laminae.toml")

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

build_execution_plan <- function(path) {
  path <- fs::path(path)

  strata <- find_strata(path)
  stratum_name <- fs::path_file(strata)

  plan <-
    strata |>
    purrr::map(purrr::pluck) |>
    purrr::set_names() |>
    purrr::map(find_laminae)

  lamina_names <-
    plan |>
    purrr::map(
      \(path) {
        fs::path_file(
          fs::path_dir(path)
        )
      }
    ) |>
    list_to_tibble("lamina_name") |>
    dplyr::select(-"stratum")

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
    dplyr::select(-"stratum")

  paths <-
    plan |>
    list_to_tibble("path")

  paths |>
    dplyr::bind_cols(script_names) |>
    dplyr::bind_cols(lamina_names) |>
    dplyr::mutate(
      stratum = fs::path_file(.data$stratum)
    )
}

list_to_tibble <- function(list, name) {
  list |>
    purrr::imap(
      \(x, idx) {
        x |>
          dplyr::as_tibble() |>
          dplyr::mutate(stratum = idx) |>
          dplyr::rename({{ name }} := .data$value)
      }
    ) |>
    purrr::list_rbind()
}
