# this needs way more cleanup but will work for now

  write_toml <- function(path, stratum_type, name = NULL, order = NULL, skip_if_fail = FALSE) {
  #force to fs::path
  path <- fs::path(path)

  # check stratum type
  checkmate::assert_choice(stratum_type, c("pipeline", "module"))
  stratum_folder <- paste0(stratum_type, "s")
  toml_type <- paste0(".", stratum_folder, ".toml")

  # Create .toml
  toml_file <- fs::path(path, stratum_folder, toml_type)
  fs::file_create(toml_file)

  # Write out the .toml file
  if (is.null(name)) {
    writeLines(
      paste0(
      "[", stratum_folder, "]\n",
      " }\n"
      ),
      toml_file
    )
  } else {
  writeLines(
    paste0(
      #just keep it basic for now add other stuff later
      "[", stratum_folder, "]\n",
      name, " = { created = ", lubridate::today(),
      ", order = ", order,
      ", skip_if_fail = ", skip_if_fail,
      " }\n"
    ),
    toml_file
  )
  }

  invisible(toml_file)
}
