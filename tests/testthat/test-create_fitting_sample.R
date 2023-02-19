testthat::skip_on_ci()
csf_filenames <- c("BCSF16_person_new", "BCSF16_family", "BCSF16_dwelling")
census_microdata_2016_paths <-
  lapply(csf_filenames, function(x) {
    system.file(
      "testdata",
      "confidential",
      "Census2016_CSV",
      paste0(x, ".csv"),
      package = "PopulationSynthesiser"
    )
  }) %>%
  setNames(nm = c("person", "family", "dwelling"))

test_that("create a fitting sample", {
  microdata <- read_census_microdata(
    census_microdata_2016_paths$person,
    census_microdata_2016_paths$family,
    census_microdata_2016_paths$dwelling,
    census_year = "2016",
    select = c("agep", "mstp", "sexp", "nprd")
  )

  checkmate::expect_data_table(
    create_fitting_sample(microdata),
    min.cols = 4,
    min.rows = 1,
    any.missing = FALSE
  )
})

test_that("shouldn't create a fitting sample from any data.frame", {
  expect_error(create_fitting_sample(cars))
})
