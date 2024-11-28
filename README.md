
<!-- README.md is generated from README.Rmd. Please edit that file -->

# strata

<!-- badges: start -->

[![R-CMD-check](https://github.com/asenetcky/strata/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/asenetcky/strata/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/asenetcky/strata/graph/badge.svg)](https://app.codecov.io/gh/asenetcky/strata)
[![CRAN
status](https://www.r-pkg.org/badges/version/strata)](https://CRAN.R-project.org/package=strata)
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

To install the latest CRAN release, just run:

``` r
install.packages("strata")
```

You can install the development version of strata from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("asenetcky/strata")
```

## ✨ Features

- Turn your R project into an automated one OR a one-click affair
- Only a single automation target - `main.R` or `main()` function
- Simple and consistent built-in logging
- Manage code execution in `.toml` files
- Quick build options for rapid prototyping

## 🚀 Getting Started Using `strata`

`strata` provides users with framework for easier automation with the
tools they already have at hand. Users will want to make a folder for
their `strata` project. `strata` works all by itself but shines best
when bundled inside of an RStudio project folder and coupled with the
[`renv`](https://cran.r-project.org/package=renv) package.

After loading and attaching the `strata` package users will want to
start hollowing out spaces for their code to live. Calling
`build_stratum()` and providing a name and path to your project folder
will add a ‘stratum’ to project, as well as a `main.R` script and a
`.strata.toml` file.

``` r
library(strata)

# Make a folder for your strata project
my_project_folder <- fs::dir_create(fs::file_temp())

# build_stratum creates a folder, a stratum,  where you can group together 
# similar code into sub-folder/s called a lamina/ae

# pro tip: build_stratum invisibly returns the stratum path
stratum_path <- 
  build_stratum(
    stratum_name = "project_setup",
    project_path = my_project_folder,
    order = 1
  )

# let's take a look at what was made

fs::dir_tree(my_project_folder, recurse = TRUE, all = TRUE)
#> /tmp/RtmpHrbp0P/file3cf19314ab03d
#> ├── main.R
#> └── strata
#>     ├── .strata.toml
#>     └── project_setup
```

``` r

# let's take a look at that .toml file
view_toml(fs::path(my_project_folder, "strata", ".strata.toml"))
#> # A tibble: 1 × 4
#>   type   name          order created   
#>   <chr>  <chr>         <int> <date>    
#> 1 strata project_setup     1 2024-11-28
```

``` r

# our stratum is empty, let's change that in the next section
```

Next users will want to call `build_lamina()` with a name and path to
your stratum you created in the previous step. This creates a sub-folder
of your stratum where you R code will live, as well as a
`.laminae.toml`. It’s good to group like-code together inside of a
‘lamina’. Users can have as many stratum as needed with as many laminae
and their associated R scripts that users deem necessary.

``` r

# remember we still have that stratum path from the previous section
# let's build some laminae you might see inside a stratum called 'project_setup'
# remember you can 1 or more R script inside of a lamina

build_lamina(
  stratum_path = stratum_path,
  lamina_name = "libraries",
  order = 1
)

build_lamina(
  stratum_path = stratum_path,
  lamina_name = "authentication",
  order = 2
)

build_lamina(
  stratum_path = stratum_path,
  lamina_name = "connections",
  order = 3
)

# Don't worry if you forget to specify an order, strata will assign one for you!
# Always check that the order assigned is the order you want

fs::dir_tree(my_project_folder, recurse = TRUE, all = TRUE)
#> /tmp/RtmpHrbp0P/file3cf19314ab03d
#> ├── main.R
#> └── strata
#>     ├── .strata.toml
#>     └── project_setup
#>         ├── .laminae.toml
#>         ├── authentication
#>         ├── connections
#>         └── libraries
```

``` r
view_toml(fs::path(stratum_path, ".laminae.toml"))
#> # A tibble: 3 × 5
#>   type    name           order skip_if_fail created   
#>   <chr>   <chr>          <int> <lgl>        <date>    
#> 1 laminae libraries          1 FALSE        2024-11-28
#> 2 laminae authentication     2 FALSE        2024-11-28
#> 3 laminae connections        3 FALSE        2024-11-28
```

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

## Examples

Here is a standard example using strata:

``` r
library(strata)

tmp <- fs::dir_create(fs::file_temp())
strata::build_stratum(
  project_path = tmp,
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

source(fs::path(tmp, "main.R"))
#> [2024-11-28 18:54:22.2387] INFO: Strata started 
#> [2024-11-28 18:54:22.2392] INFO: Stratum: first_stratum initialized 
#> [2024-11-28 18:54:22.2395] INFO: Lamina: first_lamina initialized 
#> [2024-11-28 18:54:22.2398] INFO: Executing: my_code1 
#> [1] "Hello, World!"
#> [2024-11-28 18:54:22.2402] INFO: Lamina: first_lamina finished 
#> [2024-11-28 18:54:22.2404] INFO: Lamina: second_lamina initialized 
#> [2024-11-28 18:54:22.2405] INFO: Executing: my_code2 
#> [1] "Goodbye, World!"
#> [2024-11-28 18:54:22.2410] INFO: Strata finished - duration: 0.0027 seconds
```

``` r
fs::dir_delete(tmp)
```

Users can also opt to use quick build functions if speed is the priority
and the naming conventions are not important.

``` r
tmp <- fs::dir_create(fs::file_temp())

strata::build_quick_strata_project(
  project_path = tmp,
  num_strata = 3,
  num_laminae_per = 2
)

fs::dir_tree(tmp)
#> /tmp/RtmpHrbp0P/file3cf192f839068
#> ├── main.R
#> └── strata
#>     ├── stratum_1
#>     │   ├── s1_lamina_1
#>     │   │   └── my_code.R
#>     │   └── s1_lamina_2
#>     │       └── my_code.R
#>     ├── stratum_2
#>     │   ├── s2_lamina_1
#>     │   │   └── my_code.R
#>     │   └── s2_lamina_2
#>     │       └── my_code.R
#>     └── stratum_3
#>         ├── s3_lamina_1
#>         │   └── my_code.R
#>         └── s3_lamina_2
#>             └── my_code.R
```

``` r
fs::dir_delete(tmp)
```
