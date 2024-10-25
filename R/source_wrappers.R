run_execution_plan <- function(execution_plan) {
  strata_start <- lubridate::now()

  initial_stratum <- execution_plan[1, ]$stratum
  initial_module <- execution_plan[1, ]$module_name

  log_message("Strata started")
  log_message(paste("Pipeline:", initial_stratum, "initialized"))
  log_message(paste("Module:", initial_module, "initialized"))
  for (row in seq_len(nrow(execution_plan))) {
    row_scope <- execution_plan[row, ]
    row_stratum <- row_scope$stratum
    row_module <- row_scope$module_name


    if (row_stratum != initial_stratum) {
      log_message(paste("Pipeline:", row_stratum, "initialized"))
      initial_stratum <- row_stratum
    }

    if (row_module != initial_module) {
      log_message(paste("Module:", row_module, "initialized"))
      initial_module <- row_module
    }


    source(row_scope$path)

  }


  strata_end <- lubridate::now()
  total_time <- log_total_time(strata_start, strata_end)
  log_message(
    paste("Strata finished - duration:", total_time, "seconds")
  )
}

#TODO implement the following functions for adhoc work
# pick_stratum()
# pick_module()

