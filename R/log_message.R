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
