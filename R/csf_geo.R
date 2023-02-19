#' @title Create a census Samlple File's zone table
#'
#' @description
#' For creating a geographical hierachy table for `mlfit::ml_problem()`.
#' @name csf_geo
NULL

#' Create a census Samlple File 2016's zone table
#' @export
#' @rdname csf_geo
csf_geo2016 <- function() {
  merge(
    census_2016_dictionary$place_of_usual_residence[, sa4_code_2016 := as.integer(sa4_code_2016)],
    census_2016_dictionary$statistical_areas[, sa4_code_2016 := as.integer(sa4_code_2016)],
    by = "sa4_code_2016"
  ) %>%
    .[, .(regucp = csf_code, sa2 = sa2_code_2016)] %>%
    unique(by = c("regucp", "sa2"))
}

#' Create a census Samlple File 2011's zone table
#' @export
#' @rdname csf_geo
csf_geo2011 <- function() {
  merge(
    census_2011_dictionary$areaenum[, sa4_code_2011 := as.integer(sa4_code_2011)],
    census_2011_dictionary$statistical_areas[, sa4_code_2011 := as.integer(sa4_code_2011)],
    by = "sa4_code_2011"
  ) %>%
    .[, .(regucp = area_code, sa2 = sa2_code_2011)] %>%
    unique(by = c("regucp", "sa2"))
}
