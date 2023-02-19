check_cols <- function(x, cols) {
  checkmate::assert_data_frame(x, col.names = "unique")
  all_exist <- all(cols %in% names(x))
  if (!all_exist) {
    cli::cli_alert_warning("One or more required columns don't exist: {.field {cols}}")
    return(FALSE)
  }
  return(TRUE)
}
