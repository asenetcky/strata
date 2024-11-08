#' Entry point and automation target for your strata project
#'
#' @param project_path A path to automation project folder
#' @param silent A logical flag to suppress logging output
#'
#' @return invisible execution plan
#' @export
#'
#' @examples
#' \dontrun{
#' main("/PATH/TO/PROJECT/FOLDER")
#' }
main <- function(project_path, silent = FALSE) {

  project_path <- fs::path(project_path)

  execution_plan <-
    build_execution_plan(project_path)

  run_execution_plan(execution_plan, silent)

  invisible(execution_plan)
}

build_execution_plan <- function(project_path) {

  #survey the strata
  strata <-
    find_strata(
      fs::path(project_path)
    )

  laminae <-
    find_laminae(strata$path)

  # rework order
  strata_order <-
    strata |>
    dplyr::select(name, order) |>
    dplyr::rename(stratum_order = order) |>
    unique()

  laminae |>
    dplyr::left_join(
      strata_order,
      by = dplyr::join_by(stratum == name)
    ) |>
    dplyr::mutate(new_order = order + stratum_order) |>
    dplyr::arrange(new_order) |>
    dplyr::mutate(
      order = dplyr::row_number(),
      script = fs::path_file(path)
    ) |>
    dplyr::select(
      stratum,
      lamina,
      order,
      skip_if_fail,
      created,
      script,
      path
    )
}

#given a toml file path return the relevant paths in the toml-specified order
#' @importFrom rlang .data
build_paths <- function(toml_path) {
  toml_path <- fs::path(toml_path)

  tomls <-
    toml_path |>
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

# given project folder read the strata.toml and report back
find_strata <- function(project_path) {
  parent_project <- fs::path_file(project_path)

  toml_path <-
    fs::path(project_path, "strata/.strata.toml")

  strata_paths <-
    toml_path |>
    build_paths()

  snapshot_toml(toml_path) |>
    dplyr::mutate(
      path = strata_paths,
      parent = parent_project
      ) |>
    dplyr::relocate(
      "parent",
      .before = "type"
    )
}

# given stratum folder read the laminae.toml and report back
find_laminae <- function(strata_path) {
  parent_strata <- fs::path_file(strata_path)

  toml_paths <-
    fs::path(strata_path, ".laminae.toml")

  laminae_paths <-
    toml_paths |>
    build_paths() |>
    fs::dir_ls(glob = "*.R")

  purrr::map(
    toml_paths,
    snapshot_toml
  ) |>
  purrr::list_rbind() |>
    dplyr::mutate(
      path = laminae_paths,
      stratum = parent_strata
    ) |>
    dplyr::rename(lamina = name) |>
    dplyr::select(-type)
}
