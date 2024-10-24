run_execution_plan <- function(execution_plan) {
  strata_start <- lubridate::now()

  initial_pipeline <- execution_plan[1, ]$pipeline
  initial_module <- execution_plan[1, ]$module_name

  log_message("Strata started")
  log_message(paste("Pipeline:", initial_pipeline, "initialized"))
  log_message(paste("Module:", initial_module, "initialized"))
  for (row in seq_len(nrow(execution_plan))) {
    row_scope <- execution_plan[row, ]
    row_pipeline <- row_scope$pipeline
    row_module <- row_scope$module_name


    if (row_pipeline != initial_pipeline) {
      log_message(paste("Pipeline:", row_pipeline, "initialized"))
      initial_pipeline <- row_pipeline
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
# pick_pipeline()
# pick_module()

