#' Return the log contents of a strata log file as a tibble
#'
#' If users decide to pipe the results of [`main()`] or any of the
#' logging-related functions into a log file, the contents of log file
#' can be parsed and stored in a tibble using `parse_log()`.  _Only_
#' the messages from the `log_*()` functions will be parsed, all other output
#' from the code will be ignored.
#'
#' @param log_path Path to the log file
#'
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
#' parse_log(log)
#' fs::dir_delete(tmp)
parse_log <- function(log_path) {
  log_path <- fs::path(log_path)

  if (!fs::file_exists(log_path)) stop("Log file does not exist")

  log_lines <- readLines(log_path)

  log_length <- length(log_lines)

  if (!log_length >= 1) stop("Log file is empty")

  parsed_log <-
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

      parsed_log <-
        dplyr::bind_rows(
          parsed_log,
          dplyr::tibble(
            "line_number" = line_number,
            "timestamp" = timestamp,
            "level" = level,
            "message" = message
          )
        )
    }
  }

  parsed_log |>
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
