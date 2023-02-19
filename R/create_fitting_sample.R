#' Create a reference sample
#'
#' @description
#'
#' Create a reference sample.
#'
#' @param microdata a `data.table::data.table()`.
#' @return a `data.table::data.table()` in the format that
#' requires by `mlfit::ml_problem()`.
#' @export
create_fitting_sample <- function(microdata) {
  checkmate::assert(
    checkmate::check_data_table(
      microdata,
      min.rows = 1,
      min.cols = 4,
      any.missing = FALSE
    ),
    checkmate::check_names(names(microdata), must.include = .csf_id_fields)
  )

  microdata
}
