library(dplyr)
library(data.table)
library(janitor)

load_vista1218_from_web <- function() {
  url <- "https://transport.vic.gov.au/-/media/tfv-documents/vista-12-18-260321.zip?la=en&hash=F39F3E513D07610B1C58A1BD2260FADF"
  temp <- tempfile() # a temporary file to save the downloaded data
  temp2 <- tempfile() # a temporary file to extract the downloaded data
  download.file(url, temp, mode = "wb")
  zip_info <- unzip(zipfile = temp, exdir = temp2)
  .read_table <- function(.dir) {
    if (grepl(".xlsx$", .dir)) {
      read_fn <- . %>% readxl::read_xlsx(., sheet = 1)
    } else {
      read_fn <- read.csv
    }
    read_fn(.dir) %>%
      janitor::clean_names()
  }
  persons_raw <- .read_table(grep("P_VISTA", zip_info, value = TRUE))
  households_raw <- .read_table(grep("H_VISTA", zip_info, value = TRUE))

  vista_pop_raw <- merge(households_raw, persons_raw, by = "hhid")

  dup_cols <- vista_pop_raw %>%
    dplyr::select(dplyr::contains(".")) %>%
    dplyr::select(sort(tidyselect::peek_vars())) %>%
    names() %>%
    gsub("\\..*", "", .) %>%
    unique()

  sapply(dup_cols, function(x) {
    vista_pop_raw %>%
      dplyr::select(dplyr::contains(x)) %>%
      {
        waldo::compare(.[[paste0(x, ".x")]], .[[paste0(x, ".x")]])
      }
  })

  if (length(dup_cols) != 0) {
    vista_pop_raw <-
      vista_pop_raw %>%
      dplyr::select(-dplyr::contains(".y")) %>%
      dplyr::rename_with(.fn = ~ gsub(".x", "", .x), .cols = paste0(dup_cols, ".x"))
  }

  data.table::setDT(vista_pop_raw)
  data.table::setattr(vista_pop_raw, "class", c("vista1218", class(vista_pop_raw)))
  vista_pop_raw
}

vista1218web <- load_vista1218_from_web()
usethis::use_data(vista1218web)
