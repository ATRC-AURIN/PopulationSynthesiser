library(data.table)
library(magrittr)
library(readxl)
library(janitor)
library(PopulationSynthesiser)

remove_emptied_rows <- function(x) {
  x[rowSums(is.na(x)) != ncol(x), ]
}

make_clean_item_data <- function(x, sheet, range) {
  .data <-
    readxl::read_xls(x, sheet = sheet, range = range) %>%
    as.data.table() %>%
    remove_emptied_rows() %>%
    janitor::clean_names()

  # fill na cells with previous values
  .data[, mnemonic := mnemonic[nafill(replace(.I, is.na(mnemonic), NA), "locf")]]
  .data[, data_item := data_item[nafill(replace(.I, is.na(data_item), NA), "locf")]]
  .data[, csf_code := csf_code[nafill(replace(.I, is.na(csf_code), NA), "locf")]]

  # remove the special note attached to the 'NPRD' variable.
  if (sheet == "Dwelling classifications") {
    .data[mnemonic == "NPRD(d)", mnemonic := "NPRD"]
  }

  if ("area_description" %in% names(.data)) {
    .data[, area_description := area_description[nafill(replace(.I, is.na(area_description), NA), "locf")]]
  }

  if ("census_sa4_geography_classification_code" %in% names(.data)) {
    .data <- .data[!tolower(mnemonic) %in% c("state"), ]
    .data[, sa4_code_2016 := as.numeric(sub("\\D*(\\d+).*", "\\1", census_sa4_geography_classification_code))]
  }

  if ("census_geography_classification_code" %in% names(.data)) {
    .data <- .data[!tolower(mnemonic) %in% c("stateur"), ]
    .data[tolower(mnemonic) %in% c("regu1p", "regu5p"), mnemonic := "REGUCP"]
    .data[, sa4_code_2016 := as.numeric(sub("\\D*(\\d+).*", "\\1", census_geography_classification_code))]
  }

  .data
}

census_path <- here::here("data-raw", "2016-census")

# 2037.0.30.001 - Microdata: Census of Population and Housing, Census Sample File, 2011
# ARCHIVED ISSUE Released at 11:30 AM (CANBERRA TIME) 12/12/2013
# https://www.abs.gov.au/AUSSTATS/abs@.nsf/DetailsPage/2037.0.30.0012011?OpenDocument
data_list_path <- fs::path(census_path, "data item list - 1 percent basic curf.xls")

census_2016_dictionary <-
  list(
    # Download link: https://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&Basic%20CSF%20Data%20item%20list.xls&2037.0.30.001&Data%20Cubes&23F9178E68163880CA257C3E000EE65C&0&2011&13.12.2013&Latest
    dwelling = make_clean_item_data(data_list_path, sheet = "Dwelling classifications", range = "A8:E209"),
    family = make_clean_item_data(data_list_path, sheet = "Family classifications", range = "A8:E64"),
    person = make_clean_item_data(data_list_path, sheet = "Persons classifications", range = "A8:E539"),
    place_of_usual_residence = make_clean_item_data(data_list_path, sheet = "Place of Usual Residence", range = "A8:E182"),
    place_of_enumeration = make_clean_item_data(data_list_path, sheet = "Place of Enumeration", range = "A8:E160"),
    # Source: https://www.abs.gov.au/AUSSTATS/abs@.nsf/DetailsPage/1270.0.55.001July%202011?OpenDocument#Data
    # ARCHIVED ISSUE Released at 11:30 AM (CANBERRA TIME) 23/12/2010  First Issue
    # Download link: https://www.abs.gov.au/ausstats/subscriber.nsf/log?openagent&1270055001_sa1_2011_aust_csv.zip&1270.0.55.001&Data%20Cubes&5AD36D669F284E70CA257801000C69BE&0&July%202011&23.12.2010&Latest
    # Date extracted: 12/02/2021
    statistical_areas =
      data.table::fread(fs::path(census_path, "1270055001_sa1_2016_aust_csv", "SA1_2016_AUST.csv")) %>%
        janitor::clean_names() %>%
        setnames(c("sa1_maincode_2016", "sa2_maincode_2016"), c("sa1_code_2016", "sa2_code_2016")) %>%
        .[, sa1_code_2016 := as.character(sa1_code_2016)] # avoid integer overflow
  )

usethis::use_data(census_2016_dictionary, overwrite = TRUE)
