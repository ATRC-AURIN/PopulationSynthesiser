test_that("create a fitting control table", {
  control_table <-
    system.file("testdata", "2016-nsw-sa2-ur-sex-mstp.csv", package = "PopulationSynthesiser") %>%
    read_census_tablebuilder(simplify_names = TRUE)

  create_fitting_control(control_table) %>%
    checkmate::expect_data_table(min.rows = 1, min.cols = 2)

  expect_error(
    create_fitting_control(copy(control_table) %>% setnames("count", "count2")),
    regexp = "Names must include the elements \\{'count'\\}.",
  )

  expect_error(
    create_fitting_control(copy(control_table) %>% .[, count := as.character(count)]),
    regexp = "Must be of type 'integerish', not 'character'"
  )
})
