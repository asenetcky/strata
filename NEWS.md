# strata 1.4.0

This release is all about bug fixes and improvements to the user experience.

## Breaking Changes

* Added dependency for R >= 4.1.0 due to use of base R pipe `|>`.

## New features

* `adhoc()` added to allow users to ad hoc a portion of their strata project
by name (instead of having to remember all the different file paths) (#46).

* `survey_log()` added to allow users to survey the logs in their strata project
as a dataframe (#41, #43).

* Added stricter strata project checking (#48).
  
  * added stricter path checking for functions that require paths to existing
files and folders.
  
  * added more helpful error messages for users regarding paths,
  
  * Functions will now check if a folder is a strata project or not and provide
helpful error messages if they are not strata projects.

## Fixes

* File name/path cleaning performed by strata to ensure valid path names will
will now stop blocking certain path/name manipulations.

* `adhoc_stratum()` will now properly handle existing file paths and avoid 
errors stating otherwise (#44).

* `build_execution_plan()` now properly handles the case where a laminae from
different strata have the same name (#52).

* The timestamp in the `log_*()` family of functions will now always be 24
characters long (#40).

* `build_outlined_strata_project()` will now allow for multiple laminae
per stratum (#36).

## Minor Improvements

* File name/path cleaning performed by strata to ensure valid path names will 
now ignore dashes "-" in file names.

* `adhoc_*()` functions will now "fail fast", stop execution and alert users
of problems (#45).

# strata 1.0.1

Initial CRAN Release.

## Breaking Changes

* Removed `lubridate` dependency due to license mismatch.

* Renamed `path` argument to `project_path` in `build_stratum()`.

## New Features

`strata` shipped with the following features in its initial release.

### Project Execution

* `main()` - Execute a strata project.

* `survey_strata()` - Survey the strata, laminae, and scripts in a strata 
project and return the execution order to the user.

### Building a strata project

* `build_stratum()` - Build a new stratum in a strata project.

* `build_lamina()` - Build a new lamina inside a stratum in a strata project.

* `build_outlined_strata_project()` - Build a new strata project from an 
user-specified outline.

* `build_quick_strata_project()` - Very quickly b uild a new strata project with 
standard names and structure.

### Adhoc

* `adhoc_stratum()` - Execute a single stratum ad hoc in a strata project,
ignoring all other strata.

* `adhoc_lamina()` - Execute a single lamina ad hoc in a strata project,
ignoring all other laminae in the same stratum, and all other strata.

### Logging

* `log_message()` - Log a message to stdout or stderr.

* `log_error()` - Log an error message to stderr.

* `log_total_time()` - A log helper function to print a time difference
in a standard message for logging.

### Config management

* `survey_tomls()` - List all .toml files in a project.

* `view_toml()` - Return a dataframe of the contents of a toml file.

* `edit_toml()` - Replace a toml at the user-provided path with the contents of 
a dataframe.


## Minor improvements and fixes

* Trimmed description per CRAN's request

* Added pkgdown website
