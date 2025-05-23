% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/toml-core.R
\name{edit_toml}
\alias{edit_toml}
\title{Edit a toml file by providing a dataframe replacement}
\usage{
edit_toml(original_toml_path, new_toml_dataframe)
}
\arguments{
\item{original_toml_path}{Path to the original toml file.}

\item{new_toml_dataframe}{Dataframe of the new toml file contents with the
following columns: \code{type}, \code{name}, \code{order}, \code{skip_if_fail}, \code{created}.}
}
\value{
invisible original toml file path to toml file
}
\description{
Users can use \code{edit_toml()} to edit a toml file (should they opt not to use a
text editor) by providing a dataframe of the desired contents. The function
will check the dataframe for validity and then rewrite the toml file using
the dataframe as a blueprint.
}
\section{\code{new_toml_dataframe}}{

\code{edit_toml()} will check the dataframe for the following columns:
\itemize{
\item \code{type}: The type of the toml file, a character that is  either "strata"
or "laminae"
\item \code{name}: The character string that is the name of the stratum or lamina
\item \code{order}: The numeric order of the stratum or lamina
\item \code{skip_if_fail}: (if type == laminae) A logical indicating if the lamina
should be skipped if it fails
\item \code{created}: A valid date that is the day the stratum or lamina was created
}

Unexpected columns will be dropped, and \code{edit_toml()} will warn the user.
If there are any missing columns, \code{edit_toml()} will return an error, stop
and inform the user what is missing.

If there are duplicates in the \code{order} than \code{strata} will rewrite the order
using its best guess.
}

\section{usage}{

Users using this function will likely want to combine some of the other
helpers in \code{strata}. This may looks something like this:
\itemize{
\item User runs \code{\link[=survey_tomls]{survey_tomls()}} to find all the toml files in the project
\item User runs \code{\link[=view_toml]{view_toml()}} to view the contents of the toml file and saves
to an object, like \code{original_toml} or similiar
\item User edits the \code{original_toml} object to their liking and saves as a
new object, like \code{new_toml}.
\item User runs \code{edit_toml()} with the path to the original toml and
\code{new_toml} objects and can then use \code{\link[=view_toml]{view_toml()}} to confirm the changes.
}
}

\examples{
tmp <- fs::dir_create(fs::file_temp())
strata::build_quick_strata_project(tmp, 2, 3)
original_toml_path <- survey_tomls(tmp)[[1]]
original_toml <- view_toml(original_toml_path)
original_toml
new_toml <- original_toml |>
  dplyr::mutate(
    created = as.Date("2021-01-01")
  )
new_toml_path <- edit_toml(original_toml_path, new_toml)
view_toml(new_toml_path)
fs::dir_delete(tmp)
}
