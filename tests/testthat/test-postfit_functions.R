skip_on_ci()
test_that("integerise age5p", {
  fitting_problem <- csf_fitting_problem(2011)
  fitting_problem <- fitting_problem %>%
    prefit_csf_agep_to_age5p()
  fitting_problem$refSample <- fitting_problem$refSample %>%
    postfit_integerise_age5p()
  checkmate::expect_integer(fitting_problem$refSample$age)
})

test_that("postfit_add_relationships()", {
  fitting_problem <- csf_fitting_problem(2011)
  fitting_problem$refSample <- fitting_problem$refSample %>%
    postfit_add_relationships()
  checkmate::expect_names(
    names(fitting_problem$refSample),
    must.include = c("partner_id", "father_id", "mother_id")
  )
  checkmate::expect_integer(fitting_problem$refSample$partner_id, all.missing = FALSE)
  checkmate::expect_integer(fitting_problem$refSample$father_id, all.missing = FALSE)
  checkmate::expect_integer(fitting_problem$refSample$mother_id, all.missing = FALSE)
})
