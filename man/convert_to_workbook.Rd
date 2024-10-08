% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/workbook.R
\name{convert_to_workbook}
\alias{convert_to_workbook}
\title{Convert a Blueprint to a Workbook}
\usage{
convert_to_workbook(blueprint)
}
\arguments{
\item{blueprint}{List.}
}
\value{
An 'openxlsx' wbWorkbook- and R6-class object.
}
\description{
Accept a 'blueprint' list, likely created with [read_blueprint], and convert
its content and structure to an 'openxlsx2' wbWorkbook-class object.
}
\examples{
# Read in the blueprint YAML file to a list
filepath <- system.file("extdata", "widgets.yaml", package = "yamlsheets")
blueprint <- read_blueprint(filepath)

# Convert list to wbWorkbook-class object
workbook <- convert_to_workbook(blueprint)
workbook

# openxlsx2::wb_open(workbook)  # to open temp version in spreadsheet editor

}
