
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

code_path <- fs::path(
    stratum_path,
    "first_lamina", "my_code.R"
  )
my_code <- fs::file_create(code_path)  
cat(file = my_code, "print('Hello, World!')")

source(fs::path(tmp,"main.R"))
#> [2024-10-25 07:50:59.245798] INFO: Strata started 
#> [2024-10-25 07:50:59.245914] INFO: Pipeline: first_stratum initialized 
#> [2024-10-25 07:50:59.245973] INFO: Module: first_lamina initialized 
#> [1] "Hello, World!"
#> [2024-10-25 07:50:59.246788] INFO: Strata finished - duration: 9e-04 seconds
```

What is special about using `README.Rmd` instead of just `README.md`?
You can include R chunks like so:

``` r
summary(cars)
#>      speed           dist       
#>  Min.   : 4.0   Min.   :  2.00  
#>  1st Qu.:12.0   1st Qu.: 26.00  
#>  Median :15.0   Median : 36.00  
#>  Mean   :15.4   Mean   : 42.98  
#>  3rd Qu.:19.0   3rd Qu.: 56.00  
#>  Max.   :25.0   Max.   :120.00
```

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date. `devtools::build_readme()` is handy for this.

You can also embed plots, for example:

<img src="man/figures/README-pressure-1.png" width="100%" />

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub and CRAN.
