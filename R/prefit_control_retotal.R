#' Retotal a control table using a new grand total.
#'
#' @description
#' This is useful when you want to simply project a control
#' table for a future year where a new grand total is assumed
#' but the distribution of the control remains unchanged.
#'
#' @param fitting_problem an `mlfit::ml_problem()` object.
#' @param individual_total a new grand total of the person control tables.
#' @param group_total a new grand total of the group control tables.
#' @param round a logical value whether to round the new totals. Default as `TRUE`.
#'
#' @return a new control table where the grand total equals to `total` where
#'  the proportion of each cell remains the same as the original control table.
#' @export
prefit_control_retotal <- function(fitting_problem, individual_total = NULL, group_total = NULL, round = TRUE) {
  stopifnot(is_ml_problem(fitting_problem))
  checkmate::assert_number(individual_total, lower = 1, null.ok = TRUE)
  checkmate::assert_number(group_total, lower = 1, null.ok = TRUE)
  checkmate::assert_flag(round)

  if (is.null(individual_total) & is.null(group_total)) {
    cli_alert_warning("Both {.var individual_total} and {.var group_total} are NULLs. \\
        This is likely a mistake. Please double check to make sure your inputs are correct.")
    return(fitting_problem)
  }

  if (!is.null(individual_total)) {
    cli_alert_info("Retotalling individual control tables")
    fitting_problem$controls$individual <-
      lapply(fitting_problem$controls$individual, function(x) {
        retotal_control(x,
          total = individual_total,
          count_col = fitting_problem$fieldNames$count,
          round = round
        )
      })
  }

  if (!is.null(group_total)) {
    cli_alert_info("Retotalling individual control tables")
    fitting_problem$controls$group <-
      lapply(fitting_problem$controls$group, function(x) {
        retotal_control(x,
          total = group_total,
          count_col = fitting_problem$fieldNames$count,
          round = round
        )
      })
  }

  return(fitting_problem)
}

#' @param ctrl a control table in data.frame.
#' @param total a new grand total of the control table.
#' @param count_col the count column of `ctrl`.
#' @noRd
retotal_control <- function(ctrl, total, count_col, round = TRUE) {
  ctrl <- checkmate::assert_data_frame(ctrl) %>%
    data.table::as.data.table()
  checkmate::assert_names(names(ctrl), must.include = count_col)
  checkmate::assert_count(total, positive = TRUE)
  checkmate::assert_flag(round)
  proportions <- ctrl[[count_col]] / sum(ctrl[[count_col]])
  if (round) {
    data.table::set(ctrl, j = count_col, value = round(total * proportions))
  } else {
    data.table::set(ctrl, j = count_col, value = total * proportions)
  }
  ctrl
}
