# this needs way more cleanup but will work for now

initial_pipeline_toml <- function(path, name, order) {
  path <- fs::path(path)
  toml_file <- fs::path(path, ".pipelines.toml")
  fs::file_create(toml_file)

  writeLines(
    paste0(
      "[pipelines]\n",
      name, " = { created = ", lubridate::today(),
      ", order = ", order,
      " }\n"
    ),
    toml_file
  )
  base::invisible(toml_file)
}

initial_module_toml <- function(path) {
  path <- fs::path(path)
  toml_file <- fs::path(path, ".modules.toml")
  fs::file_create(toml_file)

  writeLines(
    paste0("[modules]"),
    toml_file
  )
  base::invisible(toml_file)
}
