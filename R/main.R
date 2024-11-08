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




#TODO reconfigure this to use tibbles
#TODO combine the tibbles and keep all the extra information
#like parents and skips if fail etc...
build_execution_plan <- function(project_path) {

  #survey the strata
  strata <-
    find_strata(
      fs::path(project_path)
    )

  laminae <-
    find_laminae(strata$paths)

  #TODO sidestep all the list shenanigans
  #try joining up lam and strat etc.. and avoid list to tibble?

  # plan <-
  #   find_laminae(strata$paths)
  #
  # laminae <-
  #   plan |>
  #   purrr::map(
  #     \(path) {
  #       fs::path_file(
  #         fs::path_dir(path)
  #       )
  #     }
  #   ) |>
  #   list_to_tibble("lamina") |>
  #   dplyr::select(-"stratum")

  scripts <-
    plan |>
    purrr::map(
      \(path) {
        path |>
          fs::path_file() |>
          fs::path_ext_remove()
      }
    ) |>
    list_to_tibble("script") |>
    dplyr::select(-"stratum")

  paths <-
    plan |>
    list_to_tibble("path")

  paths |>
    dplyr::bind_cols(scripts) |>
    dplyr::bind_cols(laminae) |>
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
          dplyr::rename({{ name }} := "value")
      }
    ) |>
    purrr::list_rbind()
}

#given a toml file path return the relevant paths in the toml-specified order
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
      paths = strata_paths,
      parent = parent_project
      ) |>
    dplyr::relocate(
      "parent",
      .before = "type"
    )
}

#TODO make find_laminae (and reading the tomls) vector friendly
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
      paths = laminae_paths,
      parent = parent_strata
    ) |>
    dplyr::relocate(
      "parent",
      .before = "type"
    )
}
