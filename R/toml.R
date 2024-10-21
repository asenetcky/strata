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
      " }"
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

snapshot_toml <- function(toml_path) {
  toml_path <- fs::path(toml_path)
  toml <- RcppTOML::tomlparse(toml_path)
  toml_type <- names(toml)

  vars <- c("type", "name", "order", "skip_if_fail", "created")
  toml[[toml_type]] |>
    purrr::imap(
      \(x, idx) {
        dplyr::as_tibble(x) |>
          dplyr::mutate(
            type = toml_type,
            name = idx
          )
      }
    ) |>
    purrr::list_rbind() |>
    dplyr::select(dplyr::any_of(vars))
}

