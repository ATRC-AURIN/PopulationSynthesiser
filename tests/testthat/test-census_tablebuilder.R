ctb_testdata_dir <- system.file("testdata", "2016-aus-ur-agep.csv", package = "PopulationSynthesiser")

test_that("read example tables", {
  checkmate::expect_data_table(read_census_tablebuilder(ctb_testdata_dir), min.rows = 1)

  system.file("testdata", "2016-nsw-sa2-ur-occp.csv", package = "PopulationSynthesiser") %>%
    read_census_tablebuilder() %>%
    checkmate::expect_data_frame(min.rows = 1)

  system.file("testdata", "2016-nsw-sa2-ur-sex-mstp.csv", package = "PopulationSynthesiser") %>%
    read_census_tablebuilder(simplify_names = TRUE) %>%
    checkmate::expect_data_frame(min.rows = 1)

  system.file("testdata", "2016-nsw-sa2-dwelling-nprd.csv", package = "PopulationSynthesiser") %>%
    read_census_tablebuilder(simplify_names = TRUE) %>%
    checkmate::expect_data_frame(min.rows = 1)
})

test_that("preserves 'Total' rows", {
  res <- read_census_tablebuilder(ctb_testdata_dir, remove_totals = FALSE) == "Total"
  expect_true(sum(res) != 0)
})

test_that("removes 'Total' rows", {
  res <- read_census_tablebuilder(ctb_testdata_dir, remove_totals = TRUE) == "Total"
  expect_true(sum(res) == 0)
})

test_that("simplified row names", {
  res <- read_census_tablebuilder(ctb_testdata_dir, simplify_names = TRUE)
  checkmate::expect_character(names(res), pattern = "^[.]*[a-z]+[a-z0-9._]*$")
})
