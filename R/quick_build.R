# and then maybe another fun where the user passes a tibble of stratum_name,
# stratum_order, lamina_name, lamina_order,
# and skip_if_fail as optional(revert to default FALSE)

quick_build_strata_project <- function(project_path,
                                       num_strata = 1,
                                       num_laminae_per = 1) {

  #create project_path if it doesn't exist
  fs::dir_create(
      project_path,
    recurse = TRUE
  )

  for (i in 1:num_strata) {
    stratum_path <- build_stratum(
      path = project_path,
      stratum_name = paste0("stratum_", i),
      order = i
    )

    for (j in 1:num_laminae_per) {
      name <- paste0("s", i, "_lamina_", j)
      strata::build_lamina(
        stratum_path = stratum_path,
        lamina_name = name,
        order = j
      )
      lamina_code <- fs::path(stratum_path, name, "my_code.R")
      my_code <- fs::file_create(lamina_code)
      cat(file = my_code, "print('Hello, World!')")
    }
  }
  invisible(project_path)
}

build_outline <- function(outline) {
  # check outline
  # build project to spec
}

check_outline <- function(outline) {
  # check outline
}
