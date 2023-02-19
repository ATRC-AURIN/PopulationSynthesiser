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
    janitor::clean_names() %>%
    data.table::setnames(
      old = c("x1_percent_basic_csf_classification", "data_items"),
      new = c("basic_csf_classification", "data_item"),
      skip = TRUE
    )
  .data[, mnemonic := mnemonic[nafill(replace(.I, is.na(mnemonic), NA), "locf")]]
  .data[, data_item := data_item[nafill(replace(.I, is.na(data_item), NA), "locf")]]
  .data[, csf_code := csf_code[nafill(replace(.I, is.na(csf_code), NA), "locf")]]
  .data
}

expand_singly_age_categories <- function(x) {
  replacement <- data.frame(
    mnemonic = "AGEP",
    data_item = "Age of persons",
    csf_code = 0:24,
    census_classification_code = 0:24,
    basic_csf_classification = c("0 years", "1 year", paste0(2:24, " years"))
  )

  x %>%
    .[basic_csf_classification != "0-24 years singly", ] %>%
    rbind(replacement) %>%
    data.table::setorder(mnemonic)
}

census_path <- here::here("data-raw", "2011-census")

# 2037.0.30.001 - Microdata: Census of Population and Housing, Census Sample File, 2011
# ARCHIVED ISSUE Released at 11:30 AM (CANBERRA TIME) 12/12/2013
# https://www.abs.gov.au/AUSSTATS/abs@.nsf/DetailsPage/2037.0.30.0012011?OpenDocument
data_list_path <- fs::path(census_path, "Basic CSF Data item list.xls")

census_2011_dictionary <-
  list(
    # Download link: https://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&Basic%20CSF%20Data%20item%20list.xls&2037.0.30.001&Data%20Cubes&23F9178E68163880CA257C3E000EE65C&0&2011&13.12.2013&Latest
    dwelling = make_clean_item_data(data_list_path, sheet = "Dwelling classifications", range = "A7:E184"),
    family = make_clean_item_data(data_list_path, sheet = "Family classifications", range = "A7:E48"),
    person = make_clean_item_data(data_list_path, sheet = "Persons", range = "A7:E454") %>%
      expand_singly_age_categories(),
    # Download link: https://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&Basic%20CSF%20Geographic%20Classification.xls&2037.0.30.001&Data%20Cubes&BCC11817C6399FEECA257C3E000EE6C1&0&2011&13.12.2013&Latest
    areaenum =
      readxl::read_xls(fs::path(census_path, "Basic CSF Geographic Classification.xls"), sheet = "1% Sample File", range = "A7:C63") %>%
        janitor::clean_names() %>%
        data.table::setDT() %>%
        .[, sa4_code_2011 := lapply(asgs_statistical_region_code, function(x) {
          strsplit(x, ",") %>%
            unlist() %>%
            trimws()
        })] %>%
        .[, -"asgs_statistical_region_code"] %>%
        .[, lapply(.SD, unlist), area_code],
    # Source: https://www.abs.gov.au/AUSSTATS/abs@.nsf/DetailsPage/1270.0.55.001July%202011?OpenDocument#Data
    # ARCHIVED ISSUE Released at 11:30 AM (CANBERRA TIME) 23/12/2010  First Issue
    # Download link: https://www.abs.gov.au/ausstats/subscriber.nsf/log?openagent&1270055001_sa1_2011_aust_csv.zip&1270.0.55.001&Data%20Cubes&5AD36D669F284E70CA257801000C69BE&0&July%202011&23.12.2010&Latest
    # Date extracted: 12/02/2021
    statistical_areas =
      data.table::fread(fs::path(census_path, "1270055001_sa1_2011_aust_csv", "SA1_2011_AUST.csv")) %>%
        janitor::clean_names() %>%
        setnames(c("sa1_maincode_2011", "sa2_maincode_2011"), c("sa1_code_2011", "sa2_code_2011")) %>%
        .[, sa1_code_2011 := as.character(sa1_code_2011)] # avoid integer overflow
  )

usethis::use_data(census_2011_dictionary, overwrite = TRUE)
