  write_toml <- function(path, name, stratum_type, order = 1, skip_if_fail = FALSE) {
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
  writeLines(
    paste0(
      #just keep it basic for now add other stuff later
      "[", stratum_folder, "]\n",
      name, " = { created = ", lubridate::today(),
      ", order = ", order,
      ", skip_if_fail = ", skip_if_fail,
      " }\n"

    ),
    invisible(toml_file)
  )
}
