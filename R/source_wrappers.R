run_execution_plan <- function(execution_plan, silent = FALSE) {
  strata_start <- lubridate::now()

  initial_stratum <- execution_plan[1, ]$stratum
  initial_lamina <- execution_plan[1, ]$lamina_name
if (!silent) {
    log_message("Strata started")
    log_message(paste("Stratum:", initial_stratum, "initialized"))
    log_message(paste("Lamina:", initial_lamina, "initialized"))
    for (row in seq_len(nrow(execution_plan))) {
      row_scope <- execution_plan[row, ]
      row_stratum <- row_scope$stratum
      row_lamina <- row_scope$lamina_name


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

      log_message(paste("Executing:", row_scope$script_name))
      source(row_scope$path)
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
      row_lamina <- row_scope$lamina_name


      if (row_stratum != initial_stratum) {
        initial_stratum <- row_stratum
      }

      if (row_lamina != initial_lamina) {
        initial_lamina <- row_lamina
      }

      source(row_scope$path)
    }
  }
}

# TODO implement the following functions for adhoc work
# pick_stratum()
# pick_lamina()


#' @importFrom rlang .data
adhoc_stratum <- function(stratum_path, silent = FALSE) {
  stratum_name <-  fs::path_file(stratum_path)
  project_path <-
    fs::path_dir(
      fs::path_dir(stratum_path)
    )

  if (!check_stratum(stratum_path)) log_error("Stratum does not exist")

  execution_plan <-
    build_execution_plan(project_path) |>
    dplyr::filter(.data$stratum == stratum_name)

  run_execution_plan(execution_plan, silent)
  invisible(execution_plan)

}


#' @importFrom rlang .data
adhoc_lamina <- function(lamina_path, silent = FALSE) {
  lamina_name <-  fs::path_file(lamina_path)
  project_path <-
    purrr::reduce(
      1:3,
      \(x, y) fs::path_dir(x),
      .init = lamina_path
    )


  execution_plan <-
    build_execution_plan(project_path) |>
    dplyr::filter(.data$lamina_name == lamina_name)

  run_execution_plan(execution_plan, silent)
  invisible(execution_plan)
}
