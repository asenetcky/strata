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
