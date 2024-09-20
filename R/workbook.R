#' Convert a Blueprint to a Workbook
#'
#' Accept a 'blueprint' list, likely created with [read_blueprint], and convert
#' its content and structure to an 'openxlsx2' wbWorkbook-class object.
#'
#' @param blueprint List.
#'
#' @return An 'openxlsx' wbWorkbook- and R6-class object.
#'
#' @examples
#' # Read in the blueprint YAML file to a list
#' filepath <- system.file("extdata", "widgets.yaml", package = "yamlsheets")
#' blueprint <- read_blueprint(filepath)
#'
#' # Convert list to wbWorkbook-class object
#' workbook <- convert_to_workbook(blueprint)
#' workbook
#'
#' # openxlsx2::wb_open(workbook)  # to open temp version in spreadsheet editor
#'
#' @export
convert_to_workbook <- function(blueprint) {

  .check_convert_to_workbook(blueprint)

  wb <- openxlsx2::wb_workbook()

  tab_titles <- names(blueprint)

  for (tab_title in tab_titles) {

    wb <- openxlsx2::wb_add_worksheet(wb, tab_title)

    if (tab_title == "cover") wb <- .add_cover(wb, blueprint)
    if (tab_title == "contents") wb <- .add_contents(wb, blueprint, tab_title)
    if (tab_title == "notes") wb <- .add_notes(wb, blueprint, tab_title)
    if (!tab_title %in% c("cover", "contents", "notes")) {  # i.e. tables sheet
      wb <- .add_tables(wb, blueprint, tab_title)
    }

  }

  wb

}

#' Add a Cover Sheet to the Workbook
#' @noRd
.add_cover <- function(wb, blueprint) {

  sheet_content <- blueprint[["cover"]]
  sheet_content <- unlist(c(rbind(names(sheet_content), sheet_content)))
  sheet_content <- sheet_content[sheet_content != "sheet_title"]

  wb <- openxlsx2::wb_add_data(
    wb,
    sheet = "cover",
    x = sheet_content,
    start_row = 1
  )

  wb

}

#' Add a Contents Sheet to the Workbook
#' @noRd
.add_contents <- function(wb, blueprint, tab_title) {

  sheet_content <- blueprint[["contents"]]
  sheet_title <- sheet_content[["sheet_title"]]

  wb <- openxlsx2::wb_add_data(
    wb,
    sheet = "contents",
    x = sheet_title,
    start_row = 1
  )

  sheet_titles <- sapply(blueprint, function(.x) .x[["sheet_title"]])
  sheet_titles_table <- utils::stack(sheet_titles)[, c("ind", "values")]
  names(sheet_titles_table) <- c("Tab name", "Sheet title")

  wb <- openxlsx2::wb_add_data_table(
    wb,
    sheet = "contents",
    x = sheet_titles_table,
    start_row = 2,
    table_name = "sheet_table",
    table_style = "none",
    with_filter = FALSE
  )

  add_links <- sheet_content[["links"]]

  if (add_links) {

    tab_names <- as.character(sheet_titles_table[["Tab name"]])

    for (i in seq_along(tab_names)) {

      link <- openxlsx2::create_hyperlink(
        sheet = tab_names[i],
        row = 1,
        col = 1,
        text = tab_names[i]
      )

      wb <- openxlsx2::wb_add_formula(
        wb,
        sheet = "contents",
        x = link,
        start_col = 1,
        start_row = i + 2  # TODO: make this dynamic given pre-table metadata
      )

    }

  }

  wb

}

#' Add a Contents Sheet to the Workbook
#' @noRd
.add_notes <- function(wb, blueprint, tab_title) {

  sheet_content <- blueprint[["notes"]]
  sheet_title <- sheet_content[["sheet_title"]]

  wb <- openxlsx2::wb_add_data(
    wb,
    sheet = "notes",
    x = sheet_title,
    start_row = 1
  )

}

#' Add a Tables Sheet to the Workbook
#' @noRd
.add_tables <- function(wb, blueprint, tab_title) {

  sheet_content <- blueprint[[tab_title]]
  sheet_meta <- sheet_content[!names(sheet_content) %in% c("table", "tables")]
  sheet_meta <- unlist(sheet_meta)

  wb <- openxlsx2::wb_add_data(
    wb,
    sheet = tab_title,
    x = sheet_meta,
    start_row = 1
  )

  table_start_row <- length(sheet_meta) + 1

  table_content <-
    sheet_content[names(sheet_content) %in% c("table", "tables")]

  has_one_table <- inherits(table_content[[1]], "data.frame")

  if (has_one_table) {

    wb <- openxlsx2::wb_add_data_table(
      wb,
      sheet = tab_title,
      x = table_content[["table"]],
      start_row = table_start_row,
      table_name = tab_title,
      table_style = "none",
      with_filter = FALSE
    )

  }

  if (!has_one_table) {

    table_start_column <- 1

    for (subtable_name in names(table_content[["tables"]])) {

      sheet_content <- table_content[["tables"]][[subtable_name]]
      subtable_title <- sheet_content[["table_title"]]

      wb <- openxlsx2::wb_add_data(
        wb,
        sheet = tab_title,
        x = subtable_title,
        start_row = table_start_row,
        start_col = table_start_column
      )

      subtable <- sheet_content[["table"]]

      wb <- openxlsx2::wb_add_data_table(
        wb,
        sheet = tab_title,
        x = subtable,
        start_row = table_start_row + 1,
        start_col = table_start_column,
        table_name = subtable_name,
        table_style = "none",
        with_filter = FALSE
      )

      table_start_column <- table_start_column + ncol(subtable) + 1  # blank row

    }

  }

  wb

}


#' Check Input to 'convert_to_workbook' Function
#' @noRd
.check_convert_to_workbook <- function(blueprint) {

  is_list <- inherits(blueprint, "list")

  is_list_msg <- c(
    "{.arg blueprint} must be of class {.cls list}.",
    x = "You provided an object of class {.cls {class(blueprint)}}.",
    i = "Use {.fn yamlsheets::read_blueprint} to read a compliant yaml file into a {.cls list}."
  )

  if (!is_list) cli::cli_abort(is_list_msg)

}
