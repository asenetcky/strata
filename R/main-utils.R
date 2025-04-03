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
  strata_order <- laminae_order <- script <- toml_id <-
    strata_parent <- lamina_name <- script_path <- NULL

  find_strata(fs::path(project_path)) |>
    find_laminae() |>
    dplyr::arrange(strata_order, laminae_order, script, toml_id) |>
    dplyr::mutate(order = dplyr::row_number()) |>
    dplyr::rename(
      stratum = strata_parent,
      lamina = lamina_name,
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
  name <- created <- type <- NULL
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
      strata_path = fs::path(project_path, "strata", name),
      dir_parent = parent_project,
      project_path = project_path
    ) |>
    dplyr::rename(strata_name = name) |>
    dplyr::select(-c(created, type))
  good_paths <-
    fs::dir_exists(found_strata$strata_path) |>
    all()

  if (!good_paths) stop("Strata paths do not exist")

  found_strata
}

# given stratum folder read the laminae.toml and report back
find_laminae <- function(found_strata) {
  # handle global binds
  project_path <- toml_path <- order <- strata_order <-
    name <- strata_path <- lamina_name <- laminae_order <-
    toml_id <- lamina_path <- script_path <- NULL

  good_laminae_paths <- FALSE
  good_script_paths <- FALSE

  project_path <-
    found_strata |>
    dplyr::slice_head(n = 1) |>
    dplyr::pull(project_path)

  laminae_toml <-
    project_path |>
    find_tomls() |>
    fs::path_filter(regexp = "\\.laminae\\.toml$") |>
    tibble::as_tibble_col(column_name = "toml_path") |>
    dplyr::mutate(
      strata_parent = fs::path_file(fs::path_dir(toml_path))
    ) |>
    dplyr::left_join(found_strata, by = c("strata_parent" = "strata_name")) |>
    dplyr::rename(strata_order = order)

  if (nrow(laminae_toml) == 0) {
    rlang::abort("No .laminae.toml found")
  }

  found_laminae <-
    purrr::map2(
      laminae_toml$toml_path,
      laminae_toml$strata_order,
      \(toml, strata_order)
      snapshot_toml(toml) |>
        dplyr::rename(laminae_order = order) |>
        dplyr::mutate(strata_order = strata_order)
    ) |>
    purrr::list_rbind() |>
    dplyr::rename(lamina_name = name) |>
    dplyr::mutate(toml_id = dplyr::row_number()) |>
    dplyr::left_join(laminae_toml, by = "strata_order") |>
    dplyr::mutate(lamina_path = fs::path(strata_path, lamina_name))

  scripts <-
    found_laminae |>
    dplyr::group_by(strata_order, laminae_order, toml_id) |>
    dplyr::reframe(
      script_path = fs::dir_ls(lamina_path, glob = "*.R")
    ) |>
    dplyr::ungroup() |>
    dplyr::mutate(
      script = fs::path_file(
        fs::path_ext_remove(script_path)
      )
    )

  found_laminae <-
    found_laminae |>
    dplyr::left_join(
      scripts,
      by = dplyr::join_by("strata_order", "toml_id", "laminae_order")
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
