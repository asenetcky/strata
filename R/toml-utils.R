# given a target path, stratum name and order setup a blank slate strata toml
initial_stratum_toml <- function(path, name, order) {
  path <- fs::path(path)
  toml_file <- fs::path(path, ".strata.toml")
  fs::file_create(toml_file)

  readr::write_lines(
    paste0(
      "[strata]\n",
      name,
      " = { created = ",
      Sys.Date(),
      ", order = ",
      order,
      " }"
    ),
    toml_file
  )
  base::invisible(toml_file)
}

# given a target path setup a blank slate laminae toml
initial_lamina_toml <- function(path) {
  path <- fs::path(path)
  toml_file <- fs::path(path, ".laminae.toml")
  fs::file_create(toml_file)

  readr::write_lines(
    paste0("[laminae]"),
    toml_file
  )
  base::invisible(toml_file)
}

# given a path to a toml, read and parse the content of the toml and return
# the results as a tibble
snapshot_toml <- function(toml_path) {
  toml_path <- fs::path(toml_path)
  toml <- read_toml(toml_path)
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

# given a toml snapshot dataframe,
#' @importFrom rlang .data
manage_toml_order <- function(toml_snapshot) {
  duplicate_orders <-
    !dplyr::n_distinct(toml_snapshot$order) == base::nrow(toml_snapshot)

  if (duplicate_orders) {
    toml_name <- paste0(".", unique(toml_snapshot$type), ".toml")
    duped_orders <-
      toml_snapshot |>
      dplyr::count(order) |>
      dplyr::filter(.data$n > 1) |>
      dplyr::pull(order)

    without_dupes <-
      toml_snapshot |>
      dplyr::filter(!order %in% duped_orders) |>
      dplyr::arrange(order) |>
      dplyr::mutate(order = dplyr::row_number())

    max_order <- max(without_dupes$order, 0)

    with_dupes <-
      toml_snapshot |>
      dplyr::filter(order %in% duped_orders) |>
      dplyr::arrange(dplyr::across(dplyr::starts_with("name"))) |>
      dplyr::mutate(order = max_order + dplyr::row_number())

    toml_snapshot <-
      dplyr::bind_rows(without_dupes, with_dupes)

    log_message(
      paste(
        "Duplicate orders found in the",
        toml_name,
        "file, reordering"
      ),
      "WARN"
    )
  }
  toml_snapshot |>
    dplyr::arrange(order) |>
    dplyr::mutate(order = dplyr::row_number())
}

# given a toml path create a copy of that toml with a .bak extension
backup_toml <- function(toml_path) {
  file_root <- fs::path_dir(toml_path)
  file_name <-
    fs::path_file(toml_path) |>
    stringr::str_replace("\\.toml", "\\.bak")

  fs::file_copy(toml_path, fs::path(file_root, file_name), overwrite = TRUE)

  log_message(
    paste(
      "Backed up",
      toml_path,
      "to",
      fs::path(file_root, file_name)
    ),
    "INFO"
  )
}

# given a toml snapshot dataframe and a toml path, write a .toml file
# to that path with the contents of the dataframe
rewrite_from_dataframe <- function(toml_snapshot, toml_path) {
  toml_path <- fs::path(toml_path)

  backup_toml(toml_path)
  fs::file_delete(toml_path)

  # rewrite toml
  new_toml <-
    toml_snapshot |>
    dplyr::mutate(
      dplyr::across(
        dplyr::any_of("skip_if_fail"),
        stringr::str_to_lower
      )
    )

  write_toml_lines(new_toml, toml_path)
  invisible(toml_path)
}

# given a project path, find and list all the toml files in that project
find_tomls <- function(project_path) {
  project_path |>
    fs::path() |>
    fs::dir_ls(
      recurse = TRUE,
      all = TRUE,
      regexp = "\\.laminae\\.toml$|\\.strata\\.toml$"
    )
}
