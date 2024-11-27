# strata 1.0.1

- trim description

# strata 1.0.0

- Enhanced documentation
- Removed lubridate dependency
- Changed `path` argument to `project_path` in `build_stratum`

# strata 0.7.1

- styled with `styler` package
- added github action workflow: 'style'

# strata 0.7.0

- added `build_quick_strata_project` 
  - allows users to quickly build a project with standard names
- added `build_outlined_strata_project` 
  - allows users to quickly build a project by providing a dataframe
  outline of the expected project structure

# strata 0.6.0

- added user-facing functions for easier toml editing from inside of R
  - `survey_tomls` lists all .toml files in a project
  - `view_toml` returns a dataframe of the contents of toml
  - `edit_toml` replaces a toml at the user-provided path with the contents of a
  user-provided dataframe

# strata 0.5.0

- added survey_strata function to allow users to survey the details and 
execution order of the strata, laminae and scripts in their project folder

# strata 0.4.0

* Added pkgdown website 

# strata 0.3.0

* Added skip_if_fail feature that allows users to skip a lamina if it fails
# strata 0.2.0

* Added silence feature that allows users to suppress logging messages

# strata 0.1.1

* Added more test coverage to builders, toml and/or util related functions

# strata 0.1.0

* Basic functionality is feature-complete
