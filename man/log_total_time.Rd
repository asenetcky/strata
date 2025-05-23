% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/log-core.R
\name{log_total_time}
\alias{log_total_time}
\title{Print time difference in a standard message for logging purposes}
\usage{
log_total_time(begin, end)
}
\arguments{
\item{begin}{A data-time object, signifying the beginning or a process}

\item{end}{A data-time object, signifying the end of a process}
}
\value{
A numeric value of the time difference in seconds
}
\description{
Print time difference in a standard message for logging purposes
}
\examples{
begin <- Sys.time()
# do something
end <- Sys.time() + 999
log_total_time(begin, end)
}
\seealso{
Other log: 
\code{\link{log_error}()},
\code{\link{log_message}()},
\code{\link{survey_log}()}
}
\concept{log}
