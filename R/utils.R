clean_name <- function(name) {
  name |>
    stringr::str_trim() |>
    stringr::str_to_lower() |>
    stringr::str_replace_all("[^[:alnum:]]|\\s", "_")
}
