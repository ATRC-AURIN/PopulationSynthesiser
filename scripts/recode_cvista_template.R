#' Create CVISTA new_var
#'
#' VISTA1218's `RELATIONSHIP` variable or "Relationship to Person 1" can be
#' recreated with CSF2016's `rlhp` (Relatioship in household)
#' and `rpip` (Family/Household Reference Person Indicator).
#'
#'
#' @template cvistaRecode
#' @export
recode_cvista_template <- function(x, ...) {
  UseMethod("recode_cvista_template")
}

#' @export
#' @rdname recode_cvista_template
recode_cvista_template.csf2016 <-
  make_recode_cvista(recode_cvista_template_csf2016, c("var"), "new_var")

#' @export
#' @rdname recode_cvista_template
recode_cvista_template.vista1218 <-
  make_recode_cvista(recode_cvista_template_vista1218, c("var"), "new_var")

recode_cvista_template_csf2016 <- function(x, new_col, ...) {
  x
}

recode_cvista_template_vista1218 <- function(x, new_col, ...) {
  x
}
