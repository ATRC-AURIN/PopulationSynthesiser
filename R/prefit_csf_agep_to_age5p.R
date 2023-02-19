#' Recategorise Census Sample File's Age of Person to five-year age group
#'
#' @description
#' Turn `agep` into `age5p` (five-year age groups).
#'
#' @param fitting_problem an `mlfit::ml_problem()` object.
#'
#' @return an updated `mlfit::ml_problem()` object
#' @export
prefit_csf_agep_to_age5p <- function(fitting_problem) {
  stopifnot(is_ml_problem(fitting_problem))
  checkmate::assert_names(names(fitting_problem$refSample), must.include = "agep")

  fitting_problem$refSample <-
    data.table::copy(fitting_problem$refSample) %>%
    .[, age5p := agep] %>%
    .[age5p %in% c("1 year", paste0(c(0, 2:4), " years")), age5p := "0-4 years"] %>%
    .[age5p %in% paste0(5:9, " years"), age5p := "5-9 years"] %>%
    .[age5p %in% paste0(10:14, " years"), age5p := "10-14 years"] %>%
    .[age5p %in% paste0(15:19, " years"), age5p := "15-19 years"] %>%
    .[age5p %in% paste0(20:24, " years"), age5p := "20-24 years"]

  return(fitting_problem)
}
