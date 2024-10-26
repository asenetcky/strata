
<!-- README.md is generated from README.Rmd. Please edit that file -->

# strata

<!-- badges: start -->
<!-- badges: end -->

The goal of strata is to provide a framework for workflow automation and
reproducible analyses for R users and teams who may not have access to
many modern automation tooling and/or are otherwise
resource-constrained. Strata aims to be simple and allow users to adopt
it with minimal changes to existing code and use whatever automation
they have access to. There is only one target file users will need to
automate, `main.R`, which will run through the entire project with the
settings they specified as they build their strata of code. Strata is
designed to get out of the users’ way and play nice with packages like
`renv`, `cronR`, and `taskscheduleR`.

## Installation

You can install the development version of strata from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("asenetcky/strata")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(strata)

tmp <- fs::dir_create(fs::file_temp())
strata::build_stratum(
  path = tmp, 
  stratum_name = "first_stratum", 
  order = 1
  )

stratum_path <-  
  fs::path(
    tmp, "strata", "first_stratum"
  )
strata::build_lamina(
  stratum_path = stratum_path,
  lamina_name = "first_lamina",
  order = 1
  )
strata::build_lamina(
  stratum_path = stratum_path,
  lamina_name = "second_lamina",
  order = 2
  )

lamina_path1 <- fs::path(stratum_path, "first_lamina")
lamina_path2 <- fs::path(stratum_path, "second_lamina")
code_path1 <- fs::path(lamina_path1, "my_code1.R")
code_path2 <- fs::path(lamina_path2, "my_code2.R")


my_code1 <- fs::file_create(code_path1)  
my_code2 <- fs::file_create(code_path2)  
cat(file = my_code1, "print('Hello, World!')")
cat(file = my_code2, "print('Goodbye, World!')")

source(fs::path(tmp,"main.R"))
#> [2024-10-25 08:31:12.288163] INFO: Strata started 
#> [2024-10-25 08:31:12.288272] INFO: Stratum: first_stratum initialized 
#> [2024-10-25 08:31:12.288332] INFO: Lamina: first_lamina initialized 
#> [2024-10-25 08:31:12.288433] INFO: Executing: my_code1 
#> [1] "Hello, World!"
#> [2024-10-25 08:31:12.28873] INFO: Lamina: first_lamina finished 
#> [2024-10-25 08:31:12.288796] INFO: Lamina: second_lamina initialized 
#> [2024-10-25 08:31:12.288848] INFO: Executing: my_code2 
#> [1] "Goodbye, World!"
#> [2024-10-25 08:31:12.289503] INFO: Strata finished - duration: 0.0012 seconds
```
