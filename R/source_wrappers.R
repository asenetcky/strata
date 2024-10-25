run_execution_plan <- function(execution_plan) {
  strata_start <- lubridate::now()

  initial_stratum <- execution_plan[1, ]$stratum
  initial_lamina <- execution_plan[1, ]$lamina_name

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
}

# TODO implement the following functions for adhoc work
# pick_stratum()
# pick_lamina()
