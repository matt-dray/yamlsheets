
<!-- README.md is generated from README.Rmd. Please edit that file -->

# yamlsheets

<!-- badges: start -->

[![Project Status: Concept – Minimal or no implementation has been done
yet, or the repository is only intended to be a limited example, demo,
or
proof-of-concept.](https://www.repostatus.org/badges/latest/concept.svg)](https://www.repostatus.org/#concept)
<!-- badges: end -->

Generate spreadsheet publications that follow [best-practice guidance
from the UK government’s Analysis
Function](https://analysisfunction.civilservice.gov.uk/policy-store/releasing-statistics-in-spreadsheets/),
using a [YAML](https://yaml.org/) text file ‘blueprint’ as the input.

This package is a work-in-progress concept and may never be completed or
even reach a useful state.

## Install

Install from R Universe:

``` r
install.packages("yamlsheets", repos = "https://matt-dray.r-universe.dev")
```

Or from GitHub via {remotes}:

``` r
remotes::install_github("matt-dray/yamlsheets")
```

## Approach

Information and data to construct a spreadsheet are stored in a
particularly-formatted YAML text file, called a ‘blueprint’. There’s a
demo blueprint provided in the package:

``` r
filepath <- system.file("extdata", "widgets.yaml", package = "yamlsheets")
```

You can view the structure of this demo file by reading manually with
`yaml::read_yaml(filepath, eval.expr = TRUE)`.

<details>
<summary>
Click to read an aside about executing R code in a YAML file.
</summary>

Note that you can pass data into the YAML file on read by pre-pending
`!expr` to R code that will be executed on-read with the argument
`eval.expr = TRUE`.

You can choose to do this using the `eval.expr` argument in
`yaml::read_yaml()`:

``` r
yaml_raw <- yaml::read_yaml(filepath, eval.expr = FALSE)
yaml_evaluated <- yaml::read_yaml(filepath, eval.expr = TRUE)
```

Here you can see the raw, unevaluated R code in the YAML:

``` r
yaml_raw$table_1$table
#> [1] "read.csv(system.file(\"extdata\", \"widgets.csv\", package = \"yamlsheets\"))"
```

And here you can see it’s been evaluated and the data from the CSV file
has been read in:

``` r
yaml_evaluated$table_1$table
#>    location region count
#> 1         A  north    28
#> 2         B  north    79
#> 3         C  north    62
#> 4         D  north    26
#> 5         E  north    18
#> 6         F  south    86
#> 7         G  south    60
#> 8         H  south    49
#> 9         I  south    83
#> 10        J  south    70
```

</details>

Read the blueprint into a list:

``` r
blueprint <- yamlsheets::read_blueprint(filepath)
str(blueprint, 1)
#> List of 5
#>  $ cover   :List of 4
#>  $ contents:List of 2
#>  $ notes   :List of 2
#>  $ table_1 :List of 5
#>  $ table_2 :List of 3
```

<details>
<summary>
Click to see the full blueprint structure.
</summary>

``` r
str(blueprint)
#> List of 5
#>  $ cover   :List of 4
#>   ..$ sheet_title           : chr "Widget production in England, season 2023/2024"
#>   ..$ About this publication: chr [1:2] "This publication is about the quantity of widgets." "This is a second row of information."
#>   ..$ Period covered        : chr "The time period covered by this publication is quarter 3, 2023."
#>   ..$ Contact               : chr [1:2] "You can contact the team via email." "[example@example.com](mailto:example@example.com)"
#>  $ contents:List of 2
#>   ..$ sheet_title: chr "Contents"
#>   ..$ links      : logi TRUE
#>  $ notes   :List of 2
#>   ..$ sheet_title: chr "Notes"
#>   ..$ table      : chr "[Insert notes table later]"
#>  $ table_1 :List of 5
#>   ..$ sheet_title: chr "Table 1: Widget quantity"
#>   ..$ source     : chr "The UK Widget Survey."
#>   ..$ blanks     : chr "Blank cells indicate that data is missing."
#>   ..$ coverage   : chr "The data are for the North and South of England"
#>   ..$ table      :'data.frame':  10 obs. of  3 variables:
#>   .. ..$ location: chr [1:10] "A" "B" "C" "D" ...
#>   .. ..$ region  : chr [1:10] "north" "north" "north" "north" ...
#>   .. ..$ count   : int [1:10] 28 79 62 26 18 86 60 49 83 70
#>  $ table_2 :List of 3
#>   ..$ sheet_title: chr "Tables 2a and 2b: Widget quantity by geography"
#>   ..$ source     : chr "The UK Widget Survey."
#>   ..$ tables     :List of 2
#>   .. ..$ table_2a:List of 2
#>   .. .. ..$ table_title: chr "Table 2a: Widget quantity produced in the North of England"
#>   .. .. ..$ table      :'data.frame':    5 obs. of  2 variables:
#>   .. .. .. ..$ location: chr [1:5] "A" "B" "C" "D" ...
#>   .. .. .. ..$ count   : int [1:5] 28 79 62 26 18
#>   .. ..$ table_2b:List of 2
#>   .. .. ..$ table_title: chr "Table 2b: Widget quantity produced in the South of England"
#>   .. .. ..$ table      :'data.frame':    5 obs. of  2 variables:
#>   .. .. .. ..$ location: chr [1:5] "F" "G" "H" "I" ...
#>   .. .. .. ..$ count   : int [1:5] 86 60 49 83 70
```

</details>

Convert the blueprint to a wbWorkbook-class object:

``` r
(workbook <- yamlsheets::convert_to_workbook(blueprint))
#> A Workbook object.
#>  
#> Worksheets:
#>  Sheets: cover, contents, notes, table_1, table_2 
#>  Write order: 1, 2, 3, 4, 5
```

You can freely manipulate the `workbook` object with other {openxlsx2}
functions.

You can open a temporary copy of the workbook:

``` r
openxlsx2::wb_open(workbook)
```

Or write it to disk:

``` r
temp_file <- tempfile(fileext = ".xlsx")
openxlsx2::wb_save(workbook, temp_file)
```

## Related projects

- [{a11ytables}](https://github.com/co-analysis/a11ytables) is an R
  package.
- [{rapid.spreadsheets}](https://github.com/RAPID-ONS/rapid.spreadsheets)
  is an R package.
- [‘gptables’](https://github.com/best-practice-and-impact/gptables) is
  a Python package.
