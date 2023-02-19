test_that("morhp census2016 to cvista", {
  skip_on_ci()
  census_microdata_2016_paths <- paths_to_csf2016()
  census_year <- "2016"
  microdata <- read_census_microdata(
    census_microdata_2016_paths$person,
    census_microdata_2016_paths$family,
    census_microdata_2016_paths$dwelling,
    census_year = census_year
  )

  census_cvista <- morph_cvista(microdata, cvista_only = FALSE)

  checkmate::expect_data_table(
    x = census_cvista,
    nrows = nrow(microdata),
    col.names = "strict"
  )
})

test_that("morhp vista1218web to cvista", {
  vista_cvista <- morph_cvista(vista1218web)

  checkmate::expect_data_table(
    x = vista_cvista,
    nrows = nrow(vista1218web),
    col.names = "strict"
  )
})
