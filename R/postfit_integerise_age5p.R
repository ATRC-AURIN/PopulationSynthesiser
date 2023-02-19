#' Turn 5 year age group into a singly year
#' @param x a data.table.
#' @return a data.table with a new `age` field.
#' @export
postfit_integerise_age5p <- function(x) {
  x <- checkmate::assert_data_frame(x) %>% as.data.table()
  checkmate::assert_names(names(x), must.include = "age5p")
  x %>%
    .[, age5p_char := gsub("year|years|years or more|years and over", "", age5p) %>% trimws(.)] %>%
    .[, c("age5p_lb", "age5p_ub") := tstrsplit(age5p_char, "-", type.convert = T)] %>%
    .[, age5p_ub := fifelse(is.na(age5p_ub), 100, age5p_ub)] %>%
    .[, age := purrr::map2_int(age5p_lb, age5p_ub, ~ {
      sample(.x:.y, 1)
    })] %>%
    .[, .SD, .SDcols = grep("age5p", names(.), invert = TRUE, value = TRUE)]
}
