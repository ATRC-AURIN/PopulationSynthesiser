#' Create a control table.
#'
#' @description
#'
#' Create a control table.
#'
#' @param control_table a `data.table::data.table()`.
#' @return a `data.table::data.table()` in the format that
#' requires by `mlfit::ml_problem()`.
#' @export
create_fitting_control <- function(control_table) {
  checkmate::assert(
    checkmate::check_data_table(control_table, min.rows = 1, min.cols = 2),
    checkmate::check_names(names(control_table), must.include = "count"),
    checkmate::check_integerish(
      control_table[["count"]],
      lower = 0,
      any.missing = FALSE,
      min.len = 1
    ),
    combine = "and"
  )

  if ("counting" %in% names(control_table)) {
    cli_alert_info("Stripping the 'counting' column from the control table.")
    control_table <- control_table[, -"counting"]
  }

  control_table
}
