#' Send a standardized message to stdout or stderr
#'
#' @param message A string message to log
#' @param level The level of the message (e.g. INFO, WARNING, ERROR)
#' @param out_or_err Whether to log to stdout or stderr
#'
#' @return A message is printed to stdout or stderr
#' @export
#'
#' @examples
#' log_message("This is an info message", "INFO", "OUT")
log_message <- function(message, level = "INFO", out_or_err = "OUT") {
  # check for stdout or stderr
  checkmate::assert_choice(out_or_err, c("OUT", "ERR"))
  timestamp <- lubridate::now()

  log_message <- paste0("[", timestamp, "] ", level, ": ", message)

  if (out_or_err == "OUT") {
    cat(log_message, "\n")
  } else {
    message(log_message, "\n")
  }
}



#' Wrapper around log_message for ERROR messages in the log
#'
#' @param message A string to print to stderr
#'
#' @return A message is printed to stdout or stderr
#' @export
#'
#' @examples
#' log_message("This is an error message")
log_error <- function(message) {
  log_message(message, level = "ERROR", out_or_err = "ERR")
}


#' Print time difference in a standard for the log
#'
#' @param begin A data-time object
#' @param end A data-time object
#'
#' @return A numeric value of the time difference in seconds
#' @export
#'
#' @examples
#' log_total_time(Sys.time(), Sys.time() + 999)
log_total_time <- function(begin, end) {
  checkmate::assert_posixct(c(begin, end))

  round(
    as.numeric(
      difftime(end, begin),
      units = "secs"
    ),
    digits = 4
  )
}
