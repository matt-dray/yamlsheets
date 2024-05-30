#' Read a Blueprint YAML File
#'
#' Read to a list a 'blueprint': a YAML file that encodes the content and
#' structure of a workbook compliant with the Analysis Function's best-practice
#' spreadsheet guidelines.
#'
#' @param yaml Character. A path to a YAML file (.yaml or .yml) that contains a
#'   valid blueprint for a compliant workbook.
#' @param evaluate_r Logical. Evaluate R code provided in your YAML file?
#'   Defaults to `TRUE`.
#'
#' @details The YAML file must conform to a certain structure certain to be
#'   considered valid.
#'
#'   R code can be inserted to the YAML file, prepended with `!expr`, and it
#'   will be evaluated on read if `evaluate_r` is `TRUE`. It's expected that
#'   you'll use this to read pre-created tables of data to be inserted into your
#'   workbook.
#'
#' @return A nested list. The exact content and structure will depend on the
#'   supplied blueprint YAML file.
#'
#' @examples
#' # Read in the blueprint YAML file to a list
#' filepath <- system.file("extdata", "widgets.yaml", package = "yamlsheets")
#' blueprint <- read_blueprint(filepath)
#' blueprint
#'
#' @export
read_blueprint <- function(yaml, evaluate_r = TRUE) {
  .check_read_blueprint(yaml, evaluate_r)
  yaml::read_yaml(yaml, eval.expr = evaluate_r)
}

#' Check Input to 'read_blueprint' Function
#' @noRd
.check_read_blueprint <- function(yaml, evaluate_r) {

  is_char <- inherits(yaml, "character")

  is_char_msg <- c(
    "{.arg yaml} must be of class {.cls character}.",
    x = "You provided an object of class {.cls {class(yaml)}}.",
    i = "Use an existing file path with extension '.yaml' or '.yml'."
  )

  if (!is_char) cli::cli_abort(is_char_msg)

  has_file_ext <- fs::path_ext(yaml) != ""

  has_file_ext_msg <- c(
    "{.arg yaml} must be an existing file path with extension '.yaml' or '.yml'.",
    x = "You provided a string without a file extension.",
    i = "Use an existing file path with extension '.yaml' or '.yml'."
  )

  if (!has_file_ext) cli::cli_abort(has_file_ext_msg)

  is_yaml <- fs::path_ext(yaml) %in% c("yaml", "yml")

  is_yaml_msg <- c(
    "{.arg yaml} must be an existing file path with extension '.yaml' or '.yml'.",
    x = "You provided a file path with extension '.{fs::path_ext(yaml)}'.",
    i = "Use an existing file path with extension '.yaml' or '.yml'."
  )

  if (!is_yaml) cli::cli_abort(is_yaml_msg)

  yaml <- fs::as_fs_path(yaml)

  yaml_exists <- fs::is_file(yaml)

  yaml_exists_msg <- c(
    "Can't find the file path provided in {.arg yaml}.",
    x = "You provided: {.file {yaml}}",
    i = "{.arg yaml} must be an existing file path with extension '.yaml' or '.yml'."
  )

  if (!yaml_exists) cli::cli_abort(yaml_exists_msg)

}
