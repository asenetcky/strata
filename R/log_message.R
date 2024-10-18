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
  timestamp <- Sys.time()

  log_message <- paste0("[", timestamp, "] ", level, ": ", message)

  if (out_or_err == "OUT") {
    cat(log_message, "\n")
  } else {
    message(log_message, "\n")
  }
}
