
<!-- README.md is generated from README.Rmd. Please edit that file -->

# {yamlsheets}

<!-- badges: start -->

[![Project Status: Concept – Minimal or no implementation has been done
yet, or the repository is only intended to be a limited example, demo,
or
proof-of-concept.](https://www.repostatus.org/badges/latest/concept.svg)](https://www.repostatus.org/#concept)
[![R-CMD-check](https://github.com/matt-dray/yamlsheets/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/matt-dray/yamlsheets/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

## Purpose

Generate spreadsheet publications that follow [best-practice guidance
from the UK Government’s Analysis
Function](https://analysisfunction.civilservice.gov.uk/policy-store/releasing-statistics-in-spreadsheets/),
using a [YAML](https://yaml.org/) text file ‘blueprint’ as the input.

This package is a work-in-progress concept to experiment with new
methods for [the {a11ytables}
package](https://github.com/co-analysis/a11ytables). It may never be
fully-featured or complete.

## Install

Install from GitHub via {remotes}:

``` r
remotes::install_github("matt-dray/yamlsheets")
```

## Quickstart

The basic workflow for {yamlsheets} has three steps:

1.  Read a ‘blueprint’, which is a YAML text file containing all the
    information you need to create your output spreadsheet.
2.  Convert the resulting list object to an {openxlsx2} wbWorkbook-class
    object, which applies structure and styles.
3.  Write the workbook to disk.

In code, that would look something like this:

``` r
read_blueprint("blueprint.yaml") |>  # pass in your YAML blueprint
  convert_to_workbook() |>  # add structure and styles
  openxlsx2::wb_save("spreadsheet.xlsx")  # write out to an xlsx file
```

You can run this code to see a demo in action:

``` r
system.file("extdata", "widgets.yaml", package = "yamlsheets") |>  # demo file
  read_blueprint() |> 
  convert_to_workbook() |> 
  openxlsx2::wb_open()  # open a temporary copy
```

## Approach

This section contains some greater depth about how {yamlsheets} works.

### Blueprint files

Information and data to construct a spreadsheet are stored in a
particularly-formatted YAML text file, called a ‘blueprint’. There’s a
demo blueprint file provided with the package:

``` r
filepath <- system.file("extdata", "widgets.yaml", package = "yamlsheets")
```

<details>
<summary>
Click to see the raw text content of the blueprint.
</summary>

``` r
cat(readLines(filepath), sep = "\n")
# cover:
#   sheet_title: Widget production in England, season 2023/2024  # mandatory main sheet title in cell A1
#   "About this publication":
#     - This publication is about the quantity of widgets.  # arbitrary section in form 'section header: text content'
#     - This is a second row of information.
#   "Period covered":
#     - The time period covered by this publication is quarter 3, 2023.
#   Contact:
#     - You can contact the team via email.
#     - "[example@example.com](mailto:example@example.com)"   # arbitrary section, use Markdown to indicate a link
# contents:
#   sheet_title: Contents
#   links: true  # whether to add a column with links to each tab
# notes:
#   sheet_title: Notes  # mandatory expected
#   table: "[Insert notes table later]"  # mandatory expected
# table_1:
#   sheet_title: "Table 1: Widget quantity"  # mandatory expected
#   source: The UK Widget Survey.  # optional expected
#   blanks: Blank cells indicate that data is missing.  # optional arbitrary
#   coverage: The data are for the North and South of England  # optional arbitrary
#   table: !expr read.csv(system.file("extdata", "widgets.csv", package = "yamlsheets"))  # mandatory expected
# table_2:
#   sheet_title: "Tables 2a and 2b: Widget quantity by geography"
#   sheet_subtitle: "Subtitle"
#   source: The UK Widget Survey.
#   tables:
#     table_2a:
#       table_title: "Table 2a: Widget quantity produced in the North of England"
#       table: !expr read.csv(system.file("extdata", "widgets_north.csv", package = "yamlsheets"))
#     table_2b:
#       table_title: "Table 2b: Widget quantity produced in the South of England"
#       table: !expr read.csv(system.file("extdata", "widgets_south.csv", package = "yamlsheets"))
```

</details>
<details>
<summary>
Click to read an aside about executing R code in a YAML file.
</summary>

You can read a YAML file with `yaml::read_yaml()`. With the argument
`eval.expr = TRUE` you can execute R code on-read by pre-pending `!expr`
to any lines of your YAML file that you want evaluated as R code. This
could, for example, be used to read in data sets stored as CSV files.

The demo blueprint in this package has the line
`table: !expr read.csv(system.file("extdata", "widgets.csv", package = "yamlsheets"))`,
which reads a demo CSV file that contains the data for Table 1. Let’s
see what happens when you choose to evaluate that line or not.

``` r
yaml_raw <- yaml::read_yaml(filepath, eval.expr = FALSE)
yaml_evaluated <- yaml::read_yaml(filepath, eval.expr = TRUE)
```

Here you can see the raw, unevaluated R code in the YAML:

``` r
yaml_raw$table_1$table
# [1] "read.csv(system.file(\"extdata\", \"widgets.csv\", package = \"yamlsheets\"))"
```

And here you can see it’s been evaluated and the data from the CSV file
has been read in:

``` r
yaml_evaluated$table_1$table
#    location region count
# 1         A  north    28
# 2         B  north    79
# 3         C  north    62
# 4         D  north    26
# 5         E  north    18
# 6         F  south    86
# 7         G  south    60
# 8         H  south    49
# 9         I  south    83
# 10        J  south    70
```

</details>

In short, each top-level key represents a sheet (`cover`, etc), with
mandatory and arbitrary sub-sections for things like `sheet_title` and
`table`. The idea is that these are validated by `read_blueprint()` and
interpreted by `convert_to_worbook()` to build each sheet of the
workbook.

### Read a blueprint

You can read in the yaml file with `yamlsheets::read_blueprint()`, which
is a wrapper around `yaml::read_yaml()` with extra validity checks built
in.

Read the blueprint into a list:

``` r
blueprint <- yamlsheets::read_blueprint(
  yaml = filepath,
  evaluate_r = TRUE,  # default
  print_checks = TRUE  # default
)
# ✔ Has cover sheet (required)
# ✔ Has content sheet (required)
# ✔ Has notes sheet (optional)
```

Note that there are arguments that let us execute R code in the YAML
blueprint (`evaluate_r`) and also to print to the console the outcome of
some validity checks (`print_checks`). The outcome of each check will
appear with a tick or cross to show it has been passed or failed.

Here’s a quick preview of the blueprint’s structure once it’s been read
in. You can see it’s now a list with one element per sheet.

``` r
str(blueprint, 1)
# List of 5
#  $ cover   :List of 4
#  $ contents:List of 2
#  $ notes   :List of 2
#  $ table_1 :List of 5
#  $ table_2 :List of 4
```

<details>
<summary>
Click to see the full blueprint structure.
</summary>

Here’s the full structure:

``` r
str(blueprint)
# List of 5
#  $ cover   :List of 4
#   ..$ sheet_title           : chr "Widget production in England, season 2023/2024"
#   ..$ About this publication: chr [1:2] "This publication is about the quantity of widgets." "This is a second row of information."
#   ..$ Period covered        : chr "The time period covered by this publication is quarter 3, 2023."
#   ..$ Contact               : chr [1:2] "You can contact the team via email." "[example@example.com](mailto:example@example.com)"
#  $ contents:List of 2
#   ..$ sheet_title: chr "Contents"
#   ..$ links      : logi TRUE
#  $ notes   :List of 2
#   ..$ sheet_title: chr "Notes"
#   ..$ table      : chr "[Insert notes table later]"
#  $ table_1 :List of 5
#   ..$ sheet_title: chr "Table 1: Widget quantity"
#   ..$ source     : chr "The UK Widget Survey."
#   ..$ blanks     : chr "Blank cells indicate that data is missing."
#   ..$ coverage   : chr "The data are for the North and South of England"
#   ..$ table      :'data.frame':   10 obs. of  3 variables:
#   .. ..$ location: chr [1:10] "A" "B" "C" "D" ...
#   .. ..$ region  : chr [1:10] "north" "north" "north" "north" ...
#   .. ..$ count   : int [1:10] 28 79 62 26 18 86 60 49 83 70
#  $ table_2 :List of 4
#   ..$ sheet_title   : chr "Tables 2a and 2b: Widget quantity by geography"
#   ..$ sheet_subtitle: chr "Subtitle"
#   ..$ source        : chr "The UK Widget Survey."
#   ..$ tables        :List of 2
#   .. ..$ table_2a:List of 2
#   .. .. ..$ table_title: chr "Table 2a: Widget quantity produced in the North of England"
#   .. .. ..$ table      :'data.frame': 5 obs. of  2 variables:
#   .. .. .. ..$ location: chr [1:5] "A" "B" "C" "D" ...
#   .. .. .. ..$ count   : int [1:5] 28 79 62 26 18
#   .. ..$ table_2b:List of 2
#   .. .. ..$ table_title: chr "Table 2b: Widget quantity produced in the South of England"
#   .. .. ..$ table      :'data.frame': 5 obs. of  2 variables:
#   .. .. .. ..$ location: chr [1:5] "F" "G" "H" "I" ...
#   .. .. .. ..$ count   : int [1:5] 86 60 49 83 70
```

And the full contents in list form:

``` r
blueprint
# $cover
# $cover$sheet_title
# [1] "Widget production in England, season 2023/2024"
# 
# $cover$`About this publication`
# [1] "This publication is about the quantity of widgets."
# [2] "This is a second row of information."              
# 
# $cover$`Period covered`
# [1] "The time period covered by this publication is quarter 3, 2023."
# 
# $cover$Contact
# [1] "You can contact the team via email."              
# [2] "[example@example.com](mailto:example@example.com)"
# 
# 
# $contents
# $contents$sheet_title
# [1] "Contents"
# 
# $contents$links
# [1] TRUE
# 
# 
# $notes
# $notes$sheet_title
# [1] "Notes"
# 
# $notes$table
# [1] "[Insert notes table later]"
# 
# 
# $table_1
# $table_1$sheet_title
# [1] "Table 1: Widget quantity"
# 
# $table_1$source
# [1] "The UK Widget Survey."
# 
# $table_1$blanks
# [1] "Blank cells indicate that data is missing."
# 
# $table_1$coverage
# [1] "The data are for the North and South of England"
# 
# $table_1$table
#    location region count
# 1         A  north    28
# 2         B  north    79
# 3         C  north    62
# 4         D  north    26
# 5         E  north    18
# 6         F  south    86
# 7         G  south    60
# 8         H  south    49
# 9         I  south    83
# 10        J  south    70
# 
# 
# $table_2
# $table_2$sheet_title
# [1] "Tables 2a and 2b: Widget quantity by geography"
# 
# $table_2$sheet_subtitle
# [1] "Subtitle"
# 
# $table_2$source
# [1] "The UK Widget Survey."
# 
# $table_2$tables
# $table_2$tables$table_2a
# $table_2$tables$table_2a$table_title
# [1] "Table 2a: Widget quantity produced in the North of England"
# 
# $table_2$tables$table_2a$table
#   location count
# 1        A    28
# 2        B    79
# 3        C    62
# 4        D    26
# 5        E    18
# 
# 
# $table_2$tables$table_2b
# $table_2$tables$table_2b$table_title
# [1] "Table 2b: Widget quantity produced in the South of England"
# 
# $table_2$tables$table_2b$table
#   location count
# 1        F    86
# 2        G    60
# 3        H    49
# 4        I    83
# 5        J    70
```

</details>

### Convert to a workbook

Convert the blueprint list to a wbWorkbook-class object to add
spreadsheet structure and style.

``` r
(workbook <- yamlsheets::convert_to_workbook(blueprint))
# A Workbook object.
#  
# Worksheets:
#  Sheets: cover, contents, notes, table_1, table_2 
#  Write order: 1, 2, 3, 4, 5
```

You can freely manipulate the object with other {openxlsx2} functions if
you have additional needs.

Finally, you can open a temporary copy of the workbook:

``` r
openxlsx2::wb_open(workbook)
```

Or write it to disk:

``` r
temp_file <- tempfile(fileext = ".xlsx")
openxlsx2::wb_save(workbook, temp_file)
```

## Comparison to {a11ytables}

Improvements in {yamlsheets} compared to {a11ytables} include:

- [{openxlsx2}](https://janmarvin.github.io/openxlsx2/) for the
  back-end, rather than
  [{openxlsx}](https://ycphs.github.io/openxlsx/index.html)
- a plain-text ‘blueprint’ system as a simplified data-input interface
  (developing [Matt’s
  suggestion](https://github.com/co-analysis/a11ytables/issues/65))
- greater flexibility to provide arbitrary pre-table content
- support for multiple tables per sheet
- use of [{cli}](https://cli.r-lib.org/) and
  [{fs}](https://fs.r-lib.org/) for improved user interfaces and
  path-handling

## Related projects

Actively-used packages include:

- [{a11ytables}](https://github.com/co-analysis/a11ytables) for R
- [{rapid.spreadsheets}](https://github.com/RAPID-ONS/rapid.spreadsheets)
  for R
- [‘gptables’](https://github.com/best-practice-and-impact/gptables) for
  Python

Another experimental project that builds on {a11ytables}:

- [{a11ytables2}](https://github.com/matt-dray/a11ytables2) for R
