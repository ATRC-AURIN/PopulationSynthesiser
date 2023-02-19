#' @title Read ABS Census of Population and Housing Microdata into a tidy format
#'
#' @description
#' This function reads
#' \href{https://www.abs.gov.au/ausstats/abs@.nsf/Latestproducts/2037.0.30.001Main%20Features32016?opendocument&tabname=Summary&prodno=2037.0.30.001&issue=2016&num=&view=}{ABS Population and Housing Microdata}
#' into a tidy format that allows you to create a fitting problem.
#'
#' @param person_file `character(1)` a path to a person microdata CSV file
#' @param family_file `character(1)` a path to a family microdata CSV file
#' @param dwelling_file `character(1)` path to a dwelling microdata CSV file
#' @param census_year `character(1)` denote the census year of the input
#'  census microdata
#' @param label `logical(1)` should the microdata be labelled? default as `TRUE`
#' @param select `character()` A vector of column names to keep. However,
#'  `abshid`, `abspid` and `absfid` are kept, regardless of what is in `select`.
#'  By default, no columns will be discarded.
#' @param include_overseas_visitors `logical(1)`, default as `FALSE`.
#' If `TRUE` all overseas visitors, those that have "RLHP" equal to
#' "Overseas visitors", will be included.
#'
#' @return a `csf` object, which is also a data.table.
#' @export
read_census_microdata <- function(person_file, family_file, dwelling_file,
                                  census_year = c("2011", "2016"),
                                  label = TRUE,
                                  select = NULL,
                                  include_overseas_visitors = FALSE) {
  checkmate::assert(
    checkmate::check_file_exists(person_file, access = "r", extension = "csv"),
    checkmate::check_file_exists(family_file, access = "r", extension = "csv"),
    checkmate::check_file_exists(dwelling_file, access = "r", extension = "csv"),
    checkmate::check_flag(label),
    checkmate::check_character(select, null.ok = TRUE),
    checkmate::check_flag(include_overseas_visitors),
    combine = "and"
  )

  original_select <- select

  if (!is.null(select)) {
    id_cols <- c("abshid", "absfid", "abspid")
    select <- c(select, id_cols, ifelse(!include_overseas_visitors, "rlhp", NULL))
    if (sum(duplicated(select)) != 0) {
      cli_alert_info(
        "Removing duplicated values in `select`: {select[duplicated(select)]}"
      )
      select <- select[!duplicated(select)]
    }
    cli_alert_info("Selecting only these variables: {.fields {select}}")
  }

  cli_alert_info("Reading micro datasets from..\n\t \\
    - person_file: {.file {person_file}}\n\t \\
    - family_file: {.file {family_file}}\n\t \\
    - dwelling_file: {.file {dwelling_file}}")

  person <- .read_csf_file(person_file, select = select)
  family <- .read_csf_file(family_file, select = select)
  dwelling <- .read_csf_file(dwelling_file, select = select)

  if (census_year == "2011") {
    family <- .read_csf_file(family_file, select = select) %>%
      .[, .SD, .SDcols = !patterns("^abspid$")]
    dwelling <- .read_csf_file(dwelling_file, select = select) %>%
      .[, .SD, .SDcols = !patterns("^abspid$|^absfid$")]
  }

  # TODO: check that all columns in select have been successfully loaded
  #       and return an error if any is missing.

  # label the columns
  if (label) {
    cli_alert_info("Replacing codes with labels")
    if (is.numeric(census_year)) {
      census_year <- as.character(census_year)
    }
    census_year <- match.arg(census_year)
    .label_census_microdata(person, "person", census_year)
    .label_census_microdata(family, "family", census_year)
    .label_census_microdata(dwelling, "dwelling", census_year)
  }

  # flatten (one data.frame with all attribute levels)
  cli::cli_alert_info("Flattening the micro datasets")
  microdata <- .flatten_census_microdata(person, family, dwelling)
  if (!include_overseas_visitors) {
    cli::cli_alert_info(
      "Removing {microdata[rlhp == 'Overseas visitor', .N]} \\
      overseas visitors"
    )
    microdata <- microdata[rlhp != "Overseas visitor", ]
    if (!is.null(original_select) && !"rlhp" %in% original_select) {
      microdata <- microdata[, -c("rlhp")]
    }
  }

  if (census_year == "2011") {
    microdata %>%
      .[, abspid := 1:.N] %>%
      .[, absfid := .GRP, by = .(abshid, absfid)]
  }

  data.table::setattr(
    x = microdata,
    name = "census_year",
    value = census_year
  )
  cli::cli_alert_info("Prepending c('csf{census_year}', 'csf') to class")
  data.table::setattr(
    x = microdata,
    name = "class",
    value = c(paste0("csf", census_year), "csf", class(microdata))
  )

  microdata
}

#' @note
#' `csf_id_cols`: ID columns of CSF 2011 and 2016
#' @export
#' @rdname read_census_microdata
csf_id_cols <- c("abshid", "absfid", "abspid")

.read_csf_file <- function(file, select) {
  data <-
    data.table::fread(file) %>%
    data.table::setnames(tolower(names(.)))
  if (!is.null(select)) {
    return(data[, .SD, .SDcols = names(data)[names(data) %in% select]])
  }
  data
}

# Merge all the microdata datasets into one dataset.
.flatten_census_microdata <- function(person, family, dwelling, remove_duplicated_cols = TRUE) {
  microdata <-
    merge(person, family, by = c("absfid", "abshid"), suffix = c("_person", "_family")) %>%
    merge(., dwelling, by = "abshid", suffix = c("_person_and_family", "_dwelling"))
  if (remove_duplicated_cols) {
    return(microdata[, .SD, .SDcols = !grepl("_", names(microdata))])
  }
  microdata
}

# Turn numeric values into its corresponding categories
# based on its variable name.
.label_census_microdata <-
  function(x, x_type, census_year, cols_ignore = NULL) {
    census_dict <- switch(census_year,
      "2011" = census_2011_dictionary,
      "2016" = census_2016_dictionary
    )

    id_cols <- c("abspid", "absfid", "abshid")
    # Here, geographical variables are ignored because there is no
    # one-to-one mapping between the geographical classification
    # used in the csf microdata and the statistical area 4 standard.
    # For example,
    # '1	NSW Capital Region, Riverina, Southern Highlands and Shoalhaven'
    # maps to '101 Capital Region', '113 Riverina', and
    # '114 Southern Highlands and Shoalhaven'.
    geographical_cols <-
      c("areaenum", "state", "regucp", "regu1p", "regu5p", "stateur")

    cols_ignore <- c(cols_ignore, geographical_cols, id_cols)

    .label_census_microdata2(x, x_type, census_dict, cols_ignore)
  }

.label_census_microdata2 <-
  function(x, x_type, census_dict, cols_ignore = NULL) {
    x_census_dict <- census_dict[[x_type]]
    for (col in names(x)[!names(x) %in% cols_ignore]) {
      rules <- x_census_dict[
        tolower(mnemonic) == col,
        .(code = as.integer(csf_code), label = basic_csf_classification)
      ]
      if (checkmate::test_names(sort(rules$label),
        identical.to = sort(unique(x[[col]]) %>% as.character())
      )) {
        cli_alert_warning("{.var {col}} is already labelled, skipping..")
        next()
      }
      labels <- merge(
        x[, .SD, .SDcols = col],
        rules,
        by.x = col,
        by.y = "code",
        sort = FALSE
      )[["label"]]
      data.table::set(x, j = col, value = labels)
    }
  }
