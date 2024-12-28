
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

## ⚙️ Installation

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

- Easily turn your R project into an automated one OR a one-click affair
- Easily view your project’s execution plan - no more hunting and
  pecking around to find out which script sources the next
- No more juggling multiple automated tasks - there is only a single
  automation target - `main.R` or `main()` function
- Simple and consistent built-in logging
- Manage code execution in `.toml` files
- Quick build options for rapid prototyping

## 🎯 Target Audience

### TODO

Who’s this for Who this isn’t for

## 🚀 Getting Started

`strata` provides users with framework for easier automation with the
tools they already have at hand. Users will want to make a folder for
their `strata` project. `strata` works all by itself but shines best
when bundled inside of an RStudio project folder and coupled with the
[`renv`](https://cran.r-project.org/package=renv) package.

### Build Strata

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
#> /tmp/RtmpAGaJma/filec950276169af
#> ├── main.R
#> └── strata
#>     ├── .strata.toml
#>     └── project_setup

# let's take a look at that .toml file
view_toml(fs::path(my_project_folder, "strata", ".strata.toml"))
#> # A tibble: 1 × 4
#>   type   name          order created   
#>   <chr>  <chr>         <int> <date>    
#> 1 strata project_setup     1 2024-12-09

# our stratum is empty, let's change that in the next section
```

### Build Laminae

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

# This could be a lamina that contains code that
# sets up your libraries for the project
build_lamina(
  stratum_path = stratum_path,
  lamina_name = "libraries",
  order = 1
)

# This could be a lamina that contains code that API keys and other credentials
# and/or makes use of the excellent `keyring` package
build_lamina(
  stratum_path = stratum_path,
  lamina_name = "authentication",
  order = 2
)

# This could be a lamina that contains code for setting up your
# database connections etc...
build_lamina(
  stratum_path = stratum_path,
  lamina_name = "connections",
  order = 3
)

# Don't worry if you forget to specify an order, strata will assign one for you!
# Always check that the order assigned is the order you want

fs::dir_tree(my_project_folder, recurse = TRUE, all = TRUE)
#> /tmp/RtmpAGaJma/filec950276169af
#> ├── main.R
#> └── strata
#>     ├── .strata.toml
#>     └── project_setup
#>         ├── .laminae.toml
#>         ├── authentication
#>         ├── connections
#>         └── libraries
view_toml(fs::path(stratum_path, ".laminae.toml"))
#> # A tibble: 3 × 5
#>   type    name           order skip_if_fail created   
#>   <chr>   <chr>          <int> <lgl>        <date>    
#> 1 laminae libraries          1 FALSE        2024-12-09
#> 2 laminae authentication     2 FALSE        2024-12-09
#> 3 laminae connections        3 FALSE        2024-12-09
```

### Adding R Scripts

Now that users have their stratum and laminae set up, they can begin
adding their R scripts to the laminae. Users can drag and drop their
existing code into the laminae folders or write their code directly in
the laminae.

``` r
# let's fill in the laminae with some placeholder code
auth_path <- fs::path(stratum_path, "authentication", "auth_code.R")
lib_path <- fs::path(stratum_path, "libraries", "lib_code.R")
conn_path <- fs::path(stratum_path, "connections", "conn_code.R")

authentication_code <- "print('I am your authentication setup code')"
libraries_code <- "print('I am your library setup code')"
connections_code <- "print('I am your connection setup code')"

purrr::walk(
  c(auth_path, lib_path, conn_path),
  \(r_file) fs::file_create(r_file)
)

purrr::walk2(
  c(auth_path, lib_path, conn_path),
  c(authentication_code, libraries_code, connections_code),
  \(r_file, code) cat(code, file = r_file, append = TRUE)
)
```

### Taking a Look

Adding all these folders and files is well and good, but how do users
keep track of it all? `strata` has you covered. This readme has
showcased a few already, but let’s recap and then look at the entire
execution plan.

``` r
# let's take a look at the project structure now
fs::dir_tree(my_project_folder, recurse = TRUE, all = TRUE)
#> /tmp/RtmpAGaJma/filec950276169af
#> ├── main.R
#> └── strata
#>     ├── .strata.toml
#>     └── project_setup
#>         ├── .laminae.toml
#>         ├── authentication
#>         │   └── auth_code.R
#>         ├── connections
#>         │   └── conn_code.R
#>         └── libraries
#>             └── lib_code.R

# Look at all those files now - let's grab the paths of only the .tomls
survey_tomls(my_project_folder)
#> /tmp/RtmpAGaJma/filec950276169af/strata/.strata.toml
#> /tmp/RtmpAGaJma/filec950276169af/strata/project_setup/.laminae.toml
```

Users can now `view_toml()` to see the contents of the `.toml` files or
edit/replace their contents as well.

The observability work-horse for most users will likely be
`survey_strata()`.

``` r
survey_strata(my_project_folder)
#> # A tibble: 3 × 7
#>   execution_order stratum_name  lamina_name script_name script_path skip_if_fail
#>             <int> <chr>         <chr>       <chr>       <fs::path>  <lgl>       
#> 1               1 project_setup libraries   lib_code    …lib_code.R FALSE       
#> 2               2 project_setup authentica… auth_code   …uth_code.R FALSE       
#> 3               3 project_setup connections conn_code   …onn_code.R FALSE       
#> # ℹ 1 more variable: created <date>
```

Users can run `survey_strata()` to get all the need-to-know about their
project. It is important to note that `survey_strata()` “sees” the
project through the eyes of the `.toml` files, and *not* the actual file
structure, which might not reflect the true nature of the strata
project. If a stratum or lamina wasn’t built with `build_stratum()` or
`build_lamina()` or added by hand to the `.tomls` it will not show up in
the survey. This provides users with the flexibility to weave their
strata project in and out of other projects or test out new ideas
without affecting the execution plan of the project.

### Running the Project

`main.R` and its associated function `main()` is the entry point to your
project and the target that users will automate the execution of. When
executed `main()` will read those `.toml` files and begin sourcing the
pipelines in the order specified by the user/.toml files, and within a
stratum it will execute the laminae in the order specified by the user
and their specific .toml file. Within a lamina the scripts will be
sourced however the user’s operating system has ordered the scripts,
often alphabetically.

There are two ways for a uaer to “run” a project:

Users can source the `main.R` script that was auto-generated when
building a stratum.

``` r
source(fs::path(my_project_folder, "main.R"))
#> [2024-12-09 16:04:51.5061] INFO: Strata started 
#> [2024-12-09 16:04:51.5069] INFO: Stratum: project_setup initialized 
#> [2024-12-09 16:04:51.5073] INFO: Lamina: libraries initialized 
#> [2024-12-09 16:04:51.5089] INFO: Executing: lib_code 
#> [1] "I am your library setup code"
#> [2024-12-09 16:04:51.5096] INFO: Lamina: libraries finished 
#> [2024-12-09 16:04:51.5100] INFO: Lamina: authentication initialized 
#> [2024-12-09 16:04:51.5103] INFO: Executing: auth_code 
#> [1] "I am your authentication setup code"
#> [2024-12-09 16:04:51.5109] INFO: Lamina: authentication finished 
#> [2024-12-09 16:04:51.5112] INFO: Lamina: connections initialized 
#> [2024-12-09 16:04:51.5115] INFO: Executing: conn_code 
#> [1] "I am your connection setup code"
#> [2024-12-09 16:04:51.5125] INFO: Strata finished - duration: 0.0067 seconds
```

Users can also just execute the `main()` function directly, all that is
needed is the path to the project. Users can also silence the logging
messages if they desire, however, any messages generated by the code in
the laminae will still be printed to the console.

``` r
main(my_project_folder, silent = TRUE)
#> [1] "I am your library setup code"
#> [1] "I am your authentication setup code"
#> [1] "I am your connection setup code"
```

That’s the core functionality of `strata`! Users build their project
with `strata` and then it stays out of their way.

## ⚡ Going a Step Further

We have our strata project, now what?  
While it might be useful to organize all the disparate parts of your
project, and to turn it into a one-click affair, we can do better.

### Implementing Automation

#### TODO

Users may not have access to the lastest and greatest automation tools
and orchestrators, but most users should have access to something like
windows task scheduler, cron jobs or similar. In fact there are already
two great packages that can help users automate their R scripts,
[`cronR`](https://cran.r-project.org/package=cronR) and
[`taskscheduleR`](https://cran.r-project.org/package=taskscheduleR).

``` r
library(taskscheduleR)

## Run our project every thursday at 0700
taskscheduler_create(
  taskname = "strata",
  rscript = fs::path(my_project_folder, "main.R"),
  schedule = "WEEKLY",
  starttime = "07:00",
  days = c("THR")
)
# TODO test this on windows ^^

# TODO throw up a cronR example as well
```

### TODO

- rework this, grab pieces and move where appropriate - Now instead of
  juggling what to automate and when, or having to remember to which
  script sources which, users can automate the entire project with a
  single task, have consistent logging messages and use `strata` to have
  eyes on the entire project and its execution plan.

## 🎁 Additional Features

### Logging

`strata` provides basic, but consistent logging functions that are used
at run time, and are available for use inside of users’ code if they
desire.

- Logging can be routed to stdout or stderr which can then be piped to
  wherever users want to store their logs.
- Logging format is consistent -
- The timestamp is always 26 characters long, including square brackets
- The timestamp is always YEAR-MONTH-DAY HOUR:MINUTE:SECOND.XXXX
- The log level follows the timestamp with a space and ends with a colon
- The message follows the log level and is separated by a space
- Logging is kept intentionally simple, but can still be parsed with
  `parse_log()` and the resulting tibble analyzed however the user
  wishes

``` r
# The core logging function is log_message, and users can mold it to their needs
log_message(
  message = "This is a message",
  level = "INFO", # Use whatever "level" you want
  out_or_err = "OUT" # Send to stdout
)
#> [2024-12-09 16:04:51.5547] INFO: This is a message

# Users can sending warnings
log_message(
  message = "This is a warning",
  level = "WARN",
  out_or_err = "ERR" # Send to stderr if user wants
)
#> [2024-12-09 16:04:51.5556] WARN: This is a warning

# log_error() is a wrapper around log_message that sends messages to stderr
log_error("This is an error message")
#> [2024-12-09 16:04:51.5570] ERROR: This is an error message

# log_total_time() is a simple function that  always prints the time
# difference in seconds

duration <-
  log_total_time(
    begin = Sys.time(),
    end = Sys.time() + 999
  )

log_message(
  paste("This took", duration, "seconds"),
  level = "INFO",
  out_or_err = "OUT"
)
#> [2024-12-09 16:04:51.5585] INFO: This took 999 seconds
```

`log_message()` and `log_error()` invisibly return a character string
copy of their output.

``` r
log_output <- log_message("I am a log message")
#> [2024-12-09 16:04:51.5631] INFO: I am a log message
log_output
#> [1] "[2024-12-09 16:04:51.5631] INFO: I am a log message"
```

`parse_log()` will return a tibble of your log file contents for you to
view. *Only* output from the `log_message()` or `log_error()` functions
will be returned from the log, any other output will be ignored.

``` r
# Build an example log
example_log <- fs::file_create(fs::file_temp(ext = "log"))

# show file is empty
readr::read_lines(example_log)
#> character(0)

# add log message
line1 <- log_message("strata started")
#> [2024-12-09 16:04:51.5752] INFO: strata started
line1 <- paste0(line1, "\n")
cat(line1, file = example_log, append = TRUE)

# nonsense output to be ignored
line2 <- "I am a line of nonsense"
line2 <- paste0(line2, "\n")
cat(line2, file = example_log, append = TRUE)

# another log message
line3 <- log_message("strata finished")
#> [2024-12-09 16:04:51.5775] INFO: strata finished
line3 <- paste0(line3, "\n")
cat(line3, file = example_log, append = TRUE)

# parse log and return tibble
# notice that the line numbers are preserved, even if content is ignored
parse_log(example_log)
#> # A tibble: 2 × 4
#>   line_number timestamp           level message        
#>         <int> <dttm>              <chr> <chr>          
#> 1           1 2024-12-09 16:04:51 INFO  strata started 
#> 2           3 2024-12-09 16:04:51 INFO  strata finished

# clean up
fs::file_delete(example_log)
```

### Quick Build

`strata` has two “quick” build options for users.

`build_quick_strata_project()` will create a project with a stratum and
laminae with some placeholder code. This is great for testing out ideas
or deploying current code into a strata project as quickly as possible
and then sorting out the names and .tomls later.

``` r
tmp <- fs::dir_create(fs::file_temp())
build_quick_strata_project(
  project_path = tmp,
  num_strata = 2,
  num_laminae_per = 3
)

fs::dir_tree(tmp)
#> /tmp/RtmpAGaJma/filec950394bf515
#> ├── main.R
#> └── strata
#>     ├── stratum_1
#>     │   ├── s1_lamina_1
#>     │   │   └── my_code.R
#>     │   ├── s1_lamina_2
#>     │   │   └── my_code.R
#>     │   └── s1_lamina_3
#>     │       └── my_code.R
#>     └── stratum_2
#>         ├── s2_lamina_1
#>         │   └── my_code.R
#>         ├── s2_lamina_2
#>         │   └── my_code.R
#>         └── s2_lamina_3
#>             └── my_code.R
```

`build_outline_strata_project()` will create a project with strata and
laminae based on an outline dataframe provided by the user. This is
great for users who have a specific vision in mind already.

``` r
tmp <- fs::dir_create(fs::file_temp())

outline <-
  dplyr::tibble(
    project_path = tmp,
    stratum_name = c(
      "data_pull",
      "data_wrangle",
      "build_model",
      "build_report"
    ),
    stratum_order = c(
      1,
      2,
      3,
      4
    ),
    lamina_name = c(
      "sql",
      "clean_data",
      "tidy_models",
      "quarto_report"
    ),
    lamina_order = c(1, 1, 1, 1),
    skip_if_fail = FALSE
  )

dplyr::glimpse(outline)
#> Rows: 4
#> Columns: 6
#> $ project_path  <fs::path> "/tmp/RtmpAGaJma/filec95028d0f61e", "/tmp/RtmpAGaJm…
#> $ stratum_name  <chr> "data_pull", "data_wrangle", "build_model", "build_repor…
#> $ stratum_order <dbl> 1, 2, 3, 4
#> $ lamina_name   <chr> "sql", "clean_data", "tidy_models", "quarto_report"
#> $ lamina_order  <dbl> 1, 1, 1, 1
#> $ skip_if_fail  <lgl> FALSE, FALSE, FALSE, FALSE

build_outlined_strata_project(outline)

fs::dir_tree(tmp)
#> /tmp/RtmpAGaJma/filec95028d0f61e
#> ├── main.R
#> └── strata
#>     ├── build_model
#>     │   └── tidy_models
#>     │       └── my_code.R
#>     ├── build_report
#>     │   └── quarto_report
#>     │       └── my_code.R
#>     ├── data_pull
#>     │   └── sql
#>     │       └── my_code.R
#>     └── data_wrangle
#>         └── clean_data
#>             └── my_code.R
survey_strata(tmp)
#> # A tibble: 4 × 7
#>   execution_order stratum_name lamina_name  script_name script_path skip_if_fail
#>             <int> <chr>        <chr>        <chr>       <fs::path>  <lgl>       
#> 1               1 data_pull    sql          my_code     …/my_code.R FALSE       
#> 2               2 data_wrangle clean_data   my_code     …/my_code.R FALSE       
#> 3               3 build_model  tidy_models  my_code     …/my_code.R FALSE       
#> 4               4 build_report quarto_repo… my_code     …/my_code.R FALSE       
#> # ℹ 1 more variable: created <date>
```

### Ad-hoc

The ability to run the entire project with `main()` is great, but if
users want to run pieces of the project ad-hoc, it would be inconvenient
to have to source the disparate pieces of code individually, and
possibly error-prone as well. Users can execute their project piecemeal
with `adhoc_stratum()` and `adhoc_lamina()`.

`adhoc_stratum()` will source the code inside of *every* lamina in the
stratum, while ignoring all other strata.

``` r
tmp <- fs::dir_create(fs::file_temp())

build_quick_strata_project(tmp, 2, 2)

adhoc_stratum(fs::path(tmp, "strata", "stratum_1"))
#> [2024-12-09 16:04:52.1476] ERROR: Stratum does not exist
#> [2024-12-09 16:04:52.1908] INFO: Strata started 
#> [2024-12-09 16:04:52.1912] INFO: Stratum: stratum_1 initialized 
#> [2024-12-09 16:04:52.1915] INFO: Lamina: s1_lamina_1 initialized 
#> [2024-12-09 16:04:52.1919] INFO: Executing: my_code 
#> [1] "I am a placeholder, do not forget to replace me!"
#> [2024-12-09 16:04:52.1925] INFO: Lamina: s1_lamina_1 finished 
#> [2024-12-09 16:04:52.1928] INFO: Lamina: s1_lamina_2 initialized 
#> [2024-12-09 16:04:52.1930] INFO: Executing: my_code 
#> [1] "I am a placeholder, do not forget to replace me!"
#> [2024-12-09 16:04:52.1935] INFO: Strata finished - duration: 0.0029 seconds
```

`adhoc_lamina()` will execute *only* the specified lamina and the code
therein contained, ignoring all other laminae inside the same stratum
and all other strata.

``` r
adhoc_lamina(fs::path(tmp, "strata", "stratum_2", "s2_lamina_2"))
#> [2024-12-09 16:04:52.2411] INFO: Strata started 
#> [2024-12-09 16:04:52.2415] INFO: Stratum: stratum_2 initialized 
#> [2024-12-09 16:04:52.2418] INFO: Lamina: s2_lamina_2 initialized 
#> [2024-12-09 16:04:52.2422] INFO: Executing: my_code 
#> [1] "I am a placeholder, do not forget to replace me!"
#> [2024-12-09 16:04:52.2428] INFO: Strata finished - duration: 0.0018 seconds
```

### Managing .tomls

Users are able to find and read .toml files in their project with the
`survey_tomls()` and `view_toml()` functions.  
Users also have options for editing their .toml files as well. Users
will always have the option to use their favorite text editor to edit
any one of the .toml files. The files may be hidden, but
`survey_tomls()` will provide the proper paths. Users can then confirm
their edits with `view_toml()` and confirm that their expected changes
appear in the tibble.

Users can opt to work with the `edit_toml()` function and stay
completely inside of R code. It is *strongly* advised users save a copy
of their target .toml file in memory using `view_toml()` to fall back
on. Users can then take a copy of that and edit it. All that is required
of `edit_toml()` is a file path to the original .toml file and the
tibble of the content they wish to replace the original .toml file with.

``` r
# create temporary folder
tmp <- fs::dir_create(fs::file_temp())

# quick build for demonstration purposes
build_quick_strata_project(tmp, 2, 2)

# survey the .tomls
toml_list <- 
  survey_tomls(tmp)

toml_list
#> /tmp/RtmpAGaJma/filec95035449022/strata/.strata.toml
#> /tmp/RtmpAGaJma/filec95035449022/strata/stratum_1/.laminae.toml
#> /tmp/RtmpAGaJma/filec95035449022/strata/stratum_2/.laminae.toml


# create copies
original_strata_toml <- view_toml(toml_list[1])
original_strata_toml 
#> # A tibble: 2 × 4
#>   type   name      order created   
#>   <chr>  <chr>     <int> <date>    
#> 1 strata stratum_1     1 2024-12-09
#> 2 strata stratum_2     2 2024-12-09

original_lamina1_toml <- view_toml(toml_list[2])
original_lamina1_toml
#> # A tibble: 2 × 5
#>   type    name        order skip_if_fail created   
#>   <chr>   <chr>       <int> <lgl>        <date>    
#> 1 laminae s1_lamina_1     1 FALSE        2024-12-09
#> 2 laminae s1_lamina_2     2 FALSE        2024-12-09

# original execution plan
original_plan <- survey_strata(tmp)
```

The originals are all backed up, now users can edit the .toml files as
they see fit.

``` r

# edit the strata .toml
# swap the order of the strata execution
new_strata_toml <-
  original_strata_toml |>
  dplyr::mutate(
    order = c(2, 1)
  ) 

# make the edits
edit_toml(
  original_toml_path = toml_list[1],
  new_toml_dataframe = new_strata_toml
)
#> [2024-12-09 16:04:52.4547] INFO: Backed up /tmp/RtmpAGaJma/filec95035449022/strata/.strata.toml to /tmp/RtmpAGaJma/filec95035449022/strata/.strata.bak

# check the order
view_toml(toml_list[1])
#> # A tibble: 2 × 4
#>   type   name      order created   
#>   <chr>  <chr>     <int> <date>    
#> 1 strata stratum_2     1 2024-12-09
#> 2 strata stratum_1     2 2024-12-09
```

Users will notice that in addition to the changes made, a backup of the
file was created in the same directory with the extension `.bak`.
Version control should be the first line of defense to protect against
loss, but this is a nice safety net. The newest backups will always
clobber the oldest, so care needs to be taken.

``` r
# edit the lamina toml
# swap the order of the lamina execution
# make laminae skip if fail
new_lamina_toml <- 
  original_lamina1_toml |>
  dplyr::mutate(
    order = c(2, 1),
    skip_if_fail = TRUE
  )
  
# make the edits
edit_toml(
  original_toml_path = toml_list[2],
  new_toml_dataframe = new_lamina_toml
)
#> [2024-12-09 16:04:52.4837] INFO: Backed up /tmp/RtmpAGaJma/filec95035449022/strata/stratum_1/.laminae.toml to /tmp/RtmpAGaJma/filec95035449022/strata/stratum_1/.laminae.bak

# check the order and skip_if_fail
view_toml(toml_list[2])
#> # A tibble: 2 × 5
#>   type    name        order skip_if_fail created   
#>   <chr>   <chr>       <int> <lgl>        <date>    
#> 1 laminae s1_lamina_2     1 TRUE         2024-12-09
#> 2 laminae s1_lamina_1     2 TRUE         2024-12-09
```

Users can now check the execution plan to see if their changes have
taken effect and how they have changed the entire project’s execution
order.

``` r
# check execution order for the entire project
survey_strata(tmp)
#> # A tibble: 4 × 7
#>   execution_order stratum_name lamina_name script_name script_path  skip_if_fail
#>             <int> <chr>        <chr>       <chr>       <fs::path>   <lgl>       
#> 1               1 stratum_2    s2_lamina_1 my_code     …1/my_code.R FALSE       
#> 2               2 stratum_2    s2_lamina_2 my_code     …2/my_code.R FALSE       
#> 3               3 stratum_1    s1_lamina_2 my_code     …2/my_code.R TRUE        
#> 4               4 stratum_1    s1_lamina_1 my_code     …1/my_code.R TRUE        
#> # ℹ 1 more variable: created <date>
```

### Skip if Fail

#### TODO
