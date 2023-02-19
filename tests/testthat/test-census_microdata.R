testthat::skip_on_ci()
census_microdata_2016_paths <- paths_to_csf2016()
census_year <- "2016"
persons <-
  data.table::fread(census_microdata_2016_paths$person) %>%
  .[RLHP != 10, ] # remove 'Overseas visitor's

test_that("minimum inputs works", {
  microdata <- read_census_microdata(
    census_microdata_2016_paths$person,
    census_microdata_2016_paths$family,
    census_microdata_2016_paths$dwelling,
    census_year = census_year
  )
  checkmate::expect_data_table(microdata, nrows = nrow(persons))

  expect_equal(attr(microdata, "census_year"), census_year)

  microdata_2 <- microdata[1:2, ][, abshid := NULL]
  expect_equal(attr(microdata_2, "census_year"), census_year)
})

test_that("select same variables twice should not affect the output", {
  cols_to_select <- c("agep", "agep")
  microdata <- read_census_microdata(
    census_microdata_2016_paths$person,
    census_microdata_2016_paths$family,
    census_microdata_2016_paths$dwelling,
    census_year = census_year,
    select = cols_to_select
  )
  checkmate::expect_data_table(
    microdata,
    nrows = nrow(persons),
    ncol = 3 + data.table::uniqueN(cols_to_select)
  )
})

test_that("select only a subset of variables", {
  cols_to_select <- c("agep", "agep", "mstp", "hhcd")
  microdata <- read_census_microdata(
    census_microdata_2016_paths$person,
    census_microdata_2016_paths$family,
    census_microdata_2016_paths$dwelling,
    census_year = census_year,
    select = cols_to_select
  )
  checkmate::expect_data_table(
    microdata,
    nrows = nrow(persons),
    ncol = 3 + data.table::uniqueN(cols_to_select)
  )
})

test_that("geographical variables should not be labelled", {
  cols_to_select <- c("areaenum", "regucp")
  microdata <- read_census_microdata(
    census_microdata_2016_paths$person,
    census_microdata_2016_paths$family,
    census_microdata_2016_paths$dwelling,
    census_year = census_year,
    select = cols_to_select
  )
  checkmate::expect_data_table(
    microdata,
    nrows = nrow(persons),
    ncol = 3 + data.table::uniqueN(cols_to_select)
  )
  for (col in cols_to_select) {
    checkmate::expect_integerish(microdata[[col]], any.missing = FALSE)
  }
})

test_that("labels are correct", {
  cols_to_select <- c("nprd")
  microdata <- read_census_microdata(
    census_microdata_2016_paths$person,
    census_microdata_2016_paths$family,
    census_microdata_2016_paths$dwelling,
    census_year = census_year,
    select = cols_to_select
  )
  microdata[abshid %in% 1:5, .(abshid, abspid, nprd)] %>%
    unique(by = "abshid") %>%
    {
      expect_equal(.[["nprd"]], c(rep("Two persons", 3), rep("One person", 2)))
    }
})
