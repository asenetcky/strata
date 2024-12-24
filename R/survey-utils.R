scout_path <- function(path) {
  # check user input
  checkmate::assert_character(path)

  path <- fs::path(path)

  # check path type
  is_dir <- fs::is_dir(path)
  is_file <- rep(FALSE, length(path))

  # check if file
  if (any(!is_dir)) {
    is_file <- fs::is_file(path)
  }
  bad_paths <- path[!is_dir & !is_file]

  # if not dir or file abort
  if (length(bad_paths) > 0) {
    msg <-
      glue::glue(
        "Path must be an accessible directory or a file:
        ",
        glue::glue_collapse(
          glue::single_quote(bad_paths),
          sep = ", ",
          last = ""
        )
      )
    rlang::abort(msg)
  }

  invisible(path)
}


scout_project <- function(path) {
  # global bindings
  pos_strata_toml <- pos_strata_folder <- ledger_id <- NULL
  has_laminae <- has_strata <- is_project <- NULL

  # check path input
  path <- scout_path(path)

  # convert to tibble
  paths <-
    tibble::as_tibble_col(path, column_name = "path")

  # assumptions
  paths <-
    paths |>
    dplyr::mutate(
      ledger_id = dplyr::row_number(),
      has_strata = FALSE,
      has_laminae = FALSE
    )

  # check for strata
  paths <-
    paths |>
    dplyr::mutate(
      pos_strata_folder = fs::path(path, "strata"),
      pos_strata_toml = fs::path(pos_strata_folder, ".strata.toml"),
      has_strata = fs::file_exists(pos_strata_toml)
    )

  # check for laminae
  laminae_tomls <-
    purrr::map2(
      paths$pos_strata_folder,
      paths$ledger_id,
      \(folder, id) {
        fs::dir_ls(
          folder,
          all = TRUE,
          recurse = TRUE,
          glob = "*.laminae.toml"
        ) |>
          tibble::as_tibble_col(column_name = "laminae_paths") |>
          dplyr::mutate(
            ledger_id = id
          )
      }
    ) |>
    purrr::list_rbind()

  paths <-
    paths |>
    dplyr::mutate(
      has_laminae = dplyr::if_else(
        ledger_id %in% laminae_tomls$ledger_id,
        TRUE,
        has_laminae
      )
    ) |>
    dplyr::mutate(
      is_project = dplyr::if_else(
        has_strata & has_laminae,
        TRUE,
        FALSE
      )
    )

  not_strata_project <-
    paths |>
    dplyr::filter(!is_project)

  if (nrow(not_strata_project) > 0) {
    msg <- glue::glue("'{not_strata_project$path}' is not a strata project
                      has strata: {not_strata_project$has_strata}
                      has laminae: {not_strata_project$has_laminae}")
    rlang::abort(msg)
  }

  paths |>
    dplyr::filter(is_project) |>
    dplyr::pull("path") |>
    invisible()
}
