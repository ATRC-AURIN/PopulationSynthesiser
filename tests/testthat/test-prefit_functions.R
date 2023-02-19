skip_on_ci()
test_that("prefit_csf_agep_to_age5p()", {
  for (year in c(2011, 2016)) {
    fitting_problem <- csf_fitting_problem(year) %>%
      prefit_csf_agep_to_age5p()
    expect_snapshot(xtabs(~ agep + age5p, data = fitting_problem$refSample))
  }
})

test_that("prefit_control_retotal", {
  fitting_problem <- csf_fitting_problem(2011)
  fitting_problem <- fitting_problem %>%
    prefit_control_retotal(individual_total = 100, group_total = 100)
  expect_snapshot(fitting_problem$controls$individual)
  expect_snapshot(fitting_problem$controls$group)
})
