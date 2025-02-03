#' Survey the layout and execution order of a strata project
#'
#' @description
#' `survey_strata()` will examine the .tomls in `project_path` provided and
#' return a dataframe with the following information about the project:
#'
#' * `stratum_name`: the name of the stratum
#' * `lamina_name`: the name of the lamina
#' * `execution_order`: the order in which the stratum-lamina-code combination
#' will be executed
#' * `script_name`: the name of the script to be executed
#' * `script_path`: the path to the script
#'
#' This is based on the contents of the .toml files, everything else is
#' "invisible" inside the strata project.
#'
#' @inheritParams main
#'
#' @family survey
#'
#' @return dataframe housing the layout of your project based on the .tomls.
#' @export
#'
#' @examples
#' tmp <- fs::dir_create(fs::file_temp())
#' build_quick_strata_project(tmp, 2, 2)
#' survey_strata(tmp)
#' fs::dir_delete(tmp)
survey_strata <- function(project_path) {
  stratum <- lamina <- path <- order <- script <- created <- NULL
  skip_if_fail <- execution_order <- script_path <- stratum_name <- NULL

  project_path <-
    project_path |>
    scout_path() |>
    scout_project()

  build_execution_plan(project_path) |>
    dplyr::rename(
      stratum_name = stratum,
      lamina_name = lamina,
      execution_order = order,
      script_name = script,
      script_path = path
    ) |>
    dplyr::relocate(
      c(skip_if_fail, created),
      .after = script_path
    ) |>
    dplyr::relocate(
      execution_order,
      .before = stratum_name
    )
}

#' Return the log contents of a strata log file as a tibble
#'
#' If users decide to pipe the results of [`main()`] or any of the
#' logging-related functions into a log file, the contents of log file
#' can be parsed and stored in a tibble using `survey_log()`.  _Only_
#' the messages from the `log_*()` functions will be parsed, all other output
#' from the code will be ignored.
#'
#' @param log_path Path to the log file
#'
#' @family survey
#' @family log
#'
#' @return A tibble of the contents of the log file
#' @export
#'
#' @examples
#' tmp <- fs::dir_create(fs::file_temp())
#' log <- fs::file_create(fs::path(tmp, "main.log"))
#' fake_log_message <- log_message("example message")
#' cat(fake_log_message, file = log)
#' survey_log(log)
#' fs::dir_delete(tmp)
survey_log <- function(log_path) {
  log_path <- scout_path(log_path)

  log_lines <- readLines(log_path)

  log_length <- length(log_lines)

  if (!log_length > 0) rlang::abort("Log file is empty")

  surveyed_log <-
    dplyr::tibble(
      "line_number" = character(),
      "timestamp" = character(),
      "level" = character(),
      "message" = character()
    )

  for (i in 1:log_length) {
    line <- log_lines[i]

    if (check_if_log_line(line)) {
      line_number <- as.character(i)
      timestamp <-
        stringr::str_sub(line, 2, 25)

      line <- stringr::str_sub(line, 28)

      level <-
        stringr::str_extract(
          line,
          "^.*?:"
        )

      level_length <- stringr::str_length(level)

      # remove colon, but if short just leave it alone
      if (level_length > 1) {
        level <- stringr::str_sub(level, 1, level_length - 1)
      }

      message <-
        stringr::str_sub(line, level_length + 2) |>
        stringr::str_trim()

      surveyed_log <-
        dplyr::bind_rows(
          surveyed_log,
          dplyr::tibble(
            "line_number" = line_number,
            "timestamp" = timestamp,
            "level" = level,
            "message" = message
          )
        )
    }
  }

  surveyed_log |>
    dplyr::mutate(
      "line_number" = as.integer(line_number),
      "timestamp" = as.POSIXct(timestamp, format = "%Y-%m-%d %H:%M:%S"),
    )
}

# helper checks if the line from the log file is from the log function family
check_if_log_line <- function(log_line) {
  # check for timestamp in first 26 characters
  timestamp <-
    log_line |>
    stringr::str_sub(1, 26) |>
    stringr::str_detect(
      "^\\[\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}\\.\\d{4}\\]"
    )

  # check for some kind of "level" after the timestamp
  level <-
    log_line |>
    stringr::str_sub(28) |>
    stringr::str_detect(
      "^.*?: "
    )

  # if both true, reasonable assumption this is log message
  all(timestamp, level)
}



#' Find all the strata-based toml files in a strata project
#'
#' @inheritParams main
#'
#' @family survey
#'
#' @return an fs_path object of all toml files.
#' @export
#'
#' @examples
#' tmp <- fs::dir_create(fs::file_temp())
#' strata::build_quick_strata_project(tmp, 2, 3)
#' survey_tomls(tmp)
#' fs::dir_delete(tmp)
survey_tomls <- function(project_path) {
  project_path |>
    scout_path() |>
    scout_project() |>
    find_tomls()
}
