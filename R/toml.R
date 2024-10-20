write_toml <- function(path, name, stratum_type, order = NULL, skip_if_fail = NULL) {
  #force to fs::path
  path <- fs::path(path)

  # check stratum type
  checkmate::assert_choice(stratum_type, c("pipeline", "module"))
  stratum_type <-
    dplyr::if_else(stratum_type == "pipeline", ".pipeline", ".module")
  toml_type <-
    dplyr::if_else(stratum_type == ".pipeline", "pipelines", "modules")

  # Create .toml
  toml_file <- fs::path(path, toml_type ,".toml")
  fs::file_create(toml_file)

  # Write out the .toml file
  writeLines(
    paste0(
      #just keep it basic for now add other stuff later
      "[", toml_type, "]\n",
      name, " = { created = ", lubridate::today(), " }\n"

    ),
    toml_file
  )
}
