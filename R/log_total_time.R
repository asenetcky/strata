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
