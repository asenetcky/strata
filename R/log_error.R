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
