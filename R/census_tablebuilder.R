#' Read Census TableBuilder generated csv files
#'
#' @description
#' This function can read
#' [Census TableBuilder](https://www.abs.gov.au/websitedbs/censushome.nsf/home/tablebuilder)
#' generated csv files without the users having to strip the
#' metadata from the files.
#'
#' @param x `character(1)` the directory to the file to be read.
#' @param remove_totals `logical(1)` Default as `TRUE`. If `TRUE`
#'  all the rows that contains 'Total' will be removed. Any fields
#'  that had the summation button selected on the Census TableBuilder
#'  will contain rows with 'Total' as a category.
#' @param simplify_names `logical(1)` Default as `TRUE`. Only keep
#' the abbrevatiated names, if available, and convert everything to
#' names that comply with R's variable name restriction, except
#' everything will be in lowercase.
#'
#' @return a `data.table::data.table()`.
#' @export
#' @examples
#' ctb_testdata_dir <-
#'   system.file("testdata", "2016-aus-ur-agep.csv",
#'     package = "PopulationSynthesiser"
#'   )
#' read_census_tablebuilder(ctb_testdata_dir)
read_census_tablebuilder <- function(x, remove_totals = TRUE, simplify_names = TRUE) {
  checkmate::assert_file_exists(x, access = "r")
  checkmate::assert_flag(remove_totals)
  start_and_end_row_indexes <- .find_ctb_start_and_end_row_indexes(x)

  cli_alert_info("Reading data from: {x}")

  control_table <- tryCatch(
    expr = {
      data.table::fread(x,
        skip = start_and_end_row_indexes[1],
        nrows = start_and_end_row_indexes[2]
      )
    },
    warning = function(w) {
      # it is normal that fread detects an extra column after
      # the count column due to the trailing comma that
      # Census TableBuilder generated hence we use this
      # TryCatch statement to detect that warning and suppress
      # its warning to not confuse the user.
      if (!grepl("column names but the data has", w)) {
        message(w)
      }
      res <- suppressWarnings({
        data.table::fread(x,
          skip = start_and_end_row_indexes[1],
          nrows = start_and_end_row_indexes[2]
        )
      })
      # drop the empty column, the last column.
      res[, 1:(ncol(res) - 1L)]
    }
  )

  if (remove_totals) {
    cli_alert_info("Removing rows with 'Total'")
    control_table <- control_table[rowSums(control_table == "Total") == 0, ]
  }

  if (simplify_names) {
    cli_alert_info("Simplifying names")
    simplified_names <-
      names(control_table) %>%
      gsub("\\s.*", "", .) %>%
      trimws(which = "both") %>%
      gsub(" ", "_", .) %>%
      tolower()
    data.table::setnames(control_table, simplified_names)
  }

  control_table
}

# @description
# Find the range of row indexes of the data in `x`.
# @return two integer values the first value is the start row index
# and the second is the end row index. Note that, the end row
# index is relative to the start row index.
.find_ctb_start_and_end_row_indexes <- function(x) {
  count_fields <- count.fields(x, sep = ",") %>%
    checkmate::assert_integerish(lower = 0)

  start_row_index <- min(which(count_fields > 2))

  if (!checkmate::test_count(start_row_index, positive = TRUE)) {
    stop(
      "The start row index cannot be determined. 'start_row_index' = ",
      start_row_index, "."
    )
  }

  end_row_index <- min(which(count_fields[-c(1:start_row_index)] == 1)) - 1L

  if (!checkmate::test_count(start_row_index, positive = TRUE)) {
    stop(
      "The end row index cannot be determined. 'end_row_index' = ",
      paste(end_row_index, collapse = ", "), "."
    )
  }

  c(start_row_index, end_row_index)
}
