
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

## Getting Started Using `strata`

`strata` provides users with framework for easier automation with the
tools they already have at hand. Users will want to make a folder for
their `strata` project. `strata` works best when bundled inside of an
RStudio project folder and the `renv` package, but can be made to work
without those is desired.

After calling the `strata` package users will want to start hollowing
out spaces for their code to live. Calling `strata::build_stratum` and
providing a name and path to your project folder will add a ‘stratum’ to
project, as well as a `main.R` script and a `.strata.toml` file.

Next users will want to call `strata::build_lamina` with a name and path
to your stratum you created in the previous step. This creates a
subfolder of your stratum where you R code will live, as well as a
`.laminae.toml`. It’s good to group like-code together inside of a
‘lamina’. Users can have as many stratum as needed with as many laminae
and their associated R scripts that users deem necessary.

`main.R` and its associated function `main` is the entry point to your
project and the target that users will automate the execution of. When
executed `main` will read those `.toml` files and begin sourcing the
pipelines in the order specified by the user/.toml files, and within a
stratum it will execute the laminae in the order specified by the user
and their specific .toml file. Within a lamina the scripts will be
sourced however the user’s operating system has ordered the scripts,
often alphabetically.

`strata` provides basic, but consistent logging functions that are used
at run time, and are available for use inside of users’ code if they
desire.

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
#> [2024-10-26 11:41:05.785279] INFO: Strata started 
#> [2024-10-26 11:41:05.785383] INFO: Stratum: first_stratum initialized 
#> [2024-10-26 11:41:05.785435] INFO: Lamina: first_lamina initialized 
#> [2024-10-26 11:41:05.78553] INFO: Executing: my_code1 
#> [1] "Hello, World!"
#> [2024-10-26 11:41:05.785805] INFO: Lamina: first_lamina finished 
#> [2024-10-26 11:41:05.785875] INFO: Lamina: second_lamina initialized 
#> [2024-10-26 11:41:05.785927] INFO: Executing: my_code2 
#> [1] "Goodbye, World!"
#> [2024-10-26 11:41:05.786538] INFO: Strata finished - duration: 0.0011 seconds
```
