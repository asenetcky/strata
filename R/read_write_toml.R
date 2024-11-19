# given a dataframe of toml content and a toml path, write the toml content to
# the toml path
write_toml_lines <- function(toml_content, toml_path) {
  toml_path <- fs::path(toml_path)
  toml_type <- base::unique(toml_content$type)

  names <-
    toml_content |>
    dplyr::select(dplyr::any_of("name"))
  orders <-
    toml_content |>
    dplyr::select(dplyr::any_of("order"))
  skip_if_fails <-
    toml_content |>
    dplyr::select(dplyr::any_of("skip_if_fail"))
  created <-
    toml_content |>
    dplyr::select(dplyr::any_of("created"))

  header <- paste0("[", toml_type, "]\n")

  if (purrr::is_empty(skip_if_fails)) {
    skip_if_fails_text <-
      dplyr::tibble(
        skip_if_fail = rep("", base::nrow(toml_content))
      )
  } else {
    skip_if_fails_text <-
      dplyr::tibble(
        skip_if_fail =
          paste0(", skip_if_fail = ", skip_if_fails$skip_if_fail)
      )
  }

  lines <-
    purrr::pmap(
      list(names, orders, skip_if_fails_text, created),
      \(name, order, skip_if_fail, created) {
        paste0(
          name, " = { created = ", created,
          ", order = ", order,
          skip_if_fail,
          " }\n"
        )
      }
    )

  fs::file_create(toml_path)

  cat(
    header,
    file = toml_path,
    append = TRUE
  )

  lines$name |>
    purrr::map(
      \(line) {
        cat(
          line,
          file = toml_path,
          append = TRUE
        )
      }
    )
}



# given a toml path, read the lines of the toml file and return a list of
# the contents
read_toml <- function(toml_path) {
  toml_path <- fs::path(toml_path)

  toml_lines <- readr::read_lines(toml_path)
  toml_type <-
    toml_lines[1] |>
    stringr::str_remove_all("\\[|\\]")


  toml_length <- length(toml_lines)

  toml_list <-
    tibble::lst(
      !!toml_type := tibble::lst()
    )


  if (toml_length > 1) {
    created <- order <- skip_if_fail <- NULL
    for (i in 2:toml_length) {
      line <- toml_lines[i]

      name <-
        stringr::word(line)

      vars <-
        line |>
        stringr::str_remove_all(
          pattern = paste0(name, " = \\{|\\}")
        ) |>
        stringr::str_trim() |>
        stringr::str_split_1(", ") |>
        purrr::map(
          \(x) {
            x |>
              stringr::str_split_1(" = ") |>
              purrr::set_names(c("key", "value"))
          }
        )


      for (i in 1:length(vars)) {
        assign(
          vars[[i]][["key"]], vars[[i]][["value"]],
        )
      }

      var_list <-
        tibble::lst(
          created = as.Date(created),
          order = as.integer(order)
        )


      if (toml_type == "laminae") {
        var_list <-
          c(var_list, tibble::lst(skip_if_fail = as.logical(skip_if_fail)))
      }

      row_vars <- tibble::lst(!!name := var_list)
      toml_list[[1]] <- c(toml_list[[1]], row_vars)
    }
  }

  toml_list
}
