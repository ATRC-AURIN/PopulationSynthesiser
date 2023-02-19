testthat::skip_on_ci()

test_that("load_toy_data() with multiple control tables", {
  n_person_tables <- 2
  n_household_tables <- 3

  toy_data <-
    load_toy_data(
      n_person_tables = n_person_tables,
      n_household_tables = n_household_tables
    )

  expect_equal(length(toy_data$person_control_tables), n_person_tables)
  expect_equal(length(toy_data$household_control_tables), n_household_tables)
})

test_that("bad zone", {
  expect_error(
    .create_toy_problem(zone = "non-existing-zone"),
    regexp = "not found"
  )
})

test_that("create a toy synthetic population from CSF 2016", {
  toy_problem <-
    .create_toy_problem(n_microdata = NULL, n_person_tables = 2, n_household_tables = 1)

  toy_fits <-
    lapply(
      .fitting_algorithms,
      function(x) {
        ml_fit(algorithm = x, toy_problem)
      }
    ) %>% setNames(.fitting_algorithms)

  checkmate::expect_list(
    toy_fits,
    types = c("ml_fit"),
    any.missing = FALSE
  )
})
