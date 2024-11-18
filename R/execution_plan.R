# given a dataframe of an execution_plan, source each script in the order
# specified in the plan, with or without logging as specified by the user
run_execution_plan <- function(execution_plan, silent = FALSE) {
  strata_start <- lubridate::now()

  initial_stratum <- execution_plan[1, ]$stratum
  initial_lamina <- execution_plan[1, ]$lamina

  if (!silent) {
    log_message("Strata started")
    log_message(paste("Stratum:", initial_stratum, "initialized"))
    log_message(paste("Lamina:", initial_lamina, "initialized"))
    for (row in seq_len(nrow(execution_plan))) {
      row_scope <- execution_plan[row, ]
      row_stratum <- row_scope$stratum
      row_lamina <- row_scope$lamina


      if (row_stratum != initial_stratum) {
        log_message(paste("Stratum:", initial_stratum, "finished"))
        log_message(paste("Stratum:", row_stratum, "initialized"))
        initial_stratum <- row_stratum
      }

      if (row_lamina != initial_lamina) {
        log_message(paste("Lamina:", initial_lamina, "finished"))
        log_message(paste("Lamina:", row_lamina, "initialized"))
        initial_lamina <- row_lamina
      }

      log_message(paste("Executing:", row_scope$script))

      if (row_scope$skip_if_fail) {
        tryCatch(
          source(row_scope$path),
          error = function(e) {
            log_error(paste("Error in", row_scope$script))
          }
        )
      } else {
        source(row_scope$path)
      }
    }


    strata_end <- lubridate::now()
    total_time <- log_total_time(strata_start, strata_end)
    log_message(
      paste("Strata finished - duration:", total_time, "seconds")
    )
  } else {
    for (row in seq_len(nrow(execution_plan))) {
      row_scope <- execution_plan[row, ]
      row_stratum <- row_scope$stratum
      row_lamina <- row_scope$lamina


      if (row_stratum != initial_stratum) {
        initial_stratum <- row_stratum
      }

      if (row_lamina != initial_lamina) {
        initial_lamina <- row_lamina
      }

       if (row_scope$skip_if_fail) {
        tryCatch(
          source(row_scope$path),
          error = function(e) {
            log_error(paste("Error in", row_scope$script, "skipping script"))
          }
        )

      } else {
        source(row_scope$path)
      }
    }
  }
}

#given a strata project return pertinent info on the project
#and the order of execution
build_execution_plan <- function(project_path) {
  path <- stratum <- lamina <- name <- type <- stratum_order <- NULL
  new_order <- skip_if_fail <- script <- created <- NULL

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
    dplyr::mutate(order = dplyr::row_number()) |>
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
  path <- lamina <- name <- type <- NULL
  parent_strata <- fs::path_file(strata_path)

  toml_paths <-
    fs::path(strata_path, ".laminae.toml")

  laminae_wscript_paths <-
    toml_paths |>
    build_paths() |>
    fs::dir_ls(glob = "*.R")

  script_names <-
    laminae_wscript_paths |>
    fs::path_file() |>
    fs::path_ext_remove()

  paths_and_scripts <-
    tibble::tibble(
      path = laminae_wscript_paths,
      script = script_names
    ) |>
    dplyr::mutate(
      lamina = fs::path_dir(.data$path),
      stratum = fs::path_file(
        fs::path_dir(lamina)
      ),
      lamina = fs::path_file(lamina)
    )


  purrr::map(
    toml_paths,
    snapshot_toml
  ) |>
    purrr::list_rbind() |>
    dplyr::rename(lamina = name) |>
    dplyr::left_join(
      paths_and_scripts,
      by = dplyr::join_by(lamina)
    ) |>
    dplyr::select(-type)
}
