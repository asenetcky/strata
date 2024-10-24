run_execution_plan <- function(execution_plan) {
  strata_start <- lubridate::now()

  for (row in seq_len(nrow(execution_plan))) {
    row_scope <- execution_plan[row, ]


    print(row_scope$path)

  }


  strata_end <- lubridate::now()
  total_time <- log_total_time(strata_start, strata_end)
  log_message(
    paste("Strata finished - duration:", total_time, "seconds")
  )
}


run_process <- function(file_path) {
  fs_path <- fs::path(file_path)
  begin <- Sys.time()
  file_name <- fs::path_file(fs_path)
  log_message(paste(file_name, "started"))

  source(fs_path)

  end <- Sys.time()
  total_time <- log_total_time(begin, end)
  log_message(
    paste(file_name, "finished - duration:", total_time, "seconds")
  )
}

run_pipeline <- function(pipeline_path) {
  fs_path <- fs::path(pipeline_path)
  begin <- Sys.time()
  pipeline_name <- fs::path_file(fs_path)

  log_message(paste("Pipeline:", pipeline_name, "initialized"))
  source(fs::path(fs_path, "pipeline_start.R"))

  end <- Sys.time()
  total_time <- log_total_time(begin, end)
  log_message(
    paste(
      "Pipeline: ", pipeline_name,
      "finished - duration:", total_time, "seconds"
    )
  )
}

run_module <- function(module_path) {
  fs_path <- fs::path(module_path)
  begin <- Sys.time()

  module_name <- fs::path_file(fs_path) |> stringr::str_remove("\\.R")
  message_begin <- paste("Module:", module_name, "initialized")
  message_end <- " - running from project folder"

  submodules <- fs::dir_ls(fs_path, glob = "*.R")
  submodule_names <-
    submodules |>
    fs::path_file() |>
    stringr::str_remove("\\.R")

  log_message(paste0(message_begin, message_end))
  purrr::map2(
    submodules,
    submodule_names,
    \(file, file_name) {
      log_message(paste("Submodule:", file_name,"initialized"))
      source(file)
    }
  )

  end <- Sys.time()
  total_time <- log_total_time(begin, end)
  log_message(
    paste(
      "Module:", module_name, "finished - duration:", total_time, "seconds"
    )
  )
}
