test_that("run_workflow() - single zone", {
  skip_on_ci()
  results <- run_workflow(here::here("atrc_workflow/test_parameters_single_zone.yaml"))
  checkmate::expect_list(
    results,
    len = 2,
    names = "unique"
  )
  checkmate::expect_names(
    names(results),
    identical.to = c("fitted_problem", "synthetic_population")
  )
})

test_that("run_workflow() - multiple zones", {
  skip_on_ci()
  results <- run_workflow(here::here("atrc_workflow/test_parameters.yaml"))
  checkmate::expect_list(
    results,
    len = 2,
    names = "unique"
  )
  checkmate::expect_names(
    names(results),
    identical.to = c("fitted_problem", "synthetic_population")
  )
})
