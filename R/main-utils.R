# given a dataframe of an execution_plan, source each script in the order
# specified in the plan, with or without logging as specified by the user
run_execution_plan <- function(execution_plan, silent = FALSE) {
  strata_start <- Sys.time()

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

    strata_end <- Sys.time()
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

# given a strata project return pertinent info on the project
# and the order of execution
build_execution_plan <- function(project_path) {
  path <- name <- script <- strata_id <- parent <-
    script_name <- script_path <- toml_id <- NULL

  # survey the strata
  strata <-
    find_strata(
      fs::path(project_path)
    )

  laminae <-
    find_laminae(strata$path) |>
    dplyr::arrange(strata_id, toml_id) |>
    dplyr::mutate(order = dplyr::row_number()) #|>

  laminae |>
    dplyr::rename(
      stratum = parent,
      lamina = name,
      script = script_name,
      path = script_path
    ) |>
    dplyr::select(
      "stratum",
      "lamina",
      "order",
      "skip_if_fail",
      "created",
      "script",
      "path"
    )
}


# given project folder read the strata.toml and report back
# based solely on toml content and not what's in the folder
find_strata <- function(project_path) {
  name <- NULL
  good_paths <- FALSE

  strata_toml <-
    find_tomls(
      fs::path(project_path)
    ) |>
    fs::path_filter(regexp = "\\.strata\\.toml$")

  if (length(strata_toml) == 0) {
    stop("No .strata.toml found")
  }

  if (length(strata_toml) > 1) {
    stop("Multiple .strata.toml found")
  }

  parent_project <- fs::path_file(project_path)

  found_strata <-
    snapshot_toml(strata_toml) |>
    dplyr::mutate(
      path = fs::path(project_path, "strata", name),
      parent = parent_project
    ) |>
    dplyr::relocate(
      "parent",
      .before = "type"
    )

  good_paths <-
    fs::dir_exists(found_strata$path) |>
    all()

  if (!good_paths) stop("Strata paths do not exist")

  found_strata
}

# given stratum folder read the laminae.toml and report back
find_laminae <- function(strata_path) {
  lamina_path <- toml_paths <- script_path <- name <- type <- NULL
  parent <- strata_id <- toml_id <- NULL

  good_laminae_paths <- FALSE
  good_script_paths <- FALSE

  ledger <-
    dplyr::tibble(
      strata_path = fs::path_expand(strata_path)
    ) |>
    dplyr::mutate(
      ledger_id = dplyr::row_number(),
      parent = fs::path_file(strata_path)
    ) |>
    dplyr::group_by(parent) |>
    dplyr::mutate(strata_id = dplyr::cur_group_id()) |>
    dplyr::ungroup()

  strata <-
    ledger |>
    dplyr::distinct(strata_path, .keep_all = TRUE)

  laminae_toml <-
    find_tomls(strata$strata_path) |>
    fs::path_filter(regexp = "\\.laminae\\.toml$") |>
    tibble::as_tibble_col(column_name = "toml_paths") |>
    dplyr::mutate(
      parent = fs::path_file(fs::path_dir(toml_paths))
    ) |>
    dplyr::left_join(strata, by = "parent")

  if (nrow(laminae_toml) == 0) {
    rlang::abort("No .laminae.toml found")
  }

  found_laminae <-
    purrr::map2(
      laminae_toml$toml_paths,
      laminae_toml$strata_id,
      \(toml, strata_id) snapshot_toml(toml) |>
        dplyr::mutate(strata_id = strata_id)
    ) |>
    purrr::list_rbind() |>
    dplyr::group_by(strata_id) |>
    dplyr::mutate(toml_id = dplyr::row_number()) |>
    dplyr::ungroup() |>
    dplyr::left_join(laminae_toml, by = "strata_id") |>
    dplyr::mutate(lamina_path = fs::path(strata_path, name)) |>
    dplyr::relocate(
      "parent",
      .before = "type"
    )

  scripts <-
    found_laminae |>
    dplyr::group_by(strata_id, toml_id) |>
    dplyr::reframe(
      script_path = fs::dir_ls(lamina_path, glob = "*.R")
    ) |>
    dplyr::mutate(
      script_name =
        fs::path_file(
          fs::path_ext_remove(script_path)
        )
    )

  found_laminae <-
    found_laminae |>
    dplyr::left_join(
      scripts,
      by = dplyr::join_by("strata_id", "toml_id")
    )

  good_laminae_paths <-
    fs::dir_exists(found_laminae$lamina_path) |>
    all()

  good_script_paths <-
    fs::file_exists(found_laminae$script_path) |>
    all()

  if (!good_laminae_paths) rlang::abort("Laminae paths do not exist")
  if (!good_script_paths) rlang::abort("Script paths do not exist")

  found_laminae
}
