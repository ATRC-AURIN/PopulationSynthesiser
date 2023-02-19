#' Morph VISTA-population
#'
#' This function helps to convert a Census population to a VISTA-like
#' population, which we refer to as CVISTA. The reason that we call this
#' a VISTA-like population is because many variables of VISTA population
#' doesn't exist or cannot be recreated using variables in Census. In some
#' cases, we need to create a new variable based on a set of variables from
#' both datasets, See the Notes section below about 'Derived variables'.
#' Hence, the final population will be more similar to VISTA than Census.
#'
#'
#' @param x VISTA or Census population.
#' @param cvista_only a logical value. Only keep the recoded columns if `TRUE`.
#'  Also, columns with 'cvista_' prefix will be renamed without the prefix.
#' @param extra_cols a character vector. Names of extra columns to be kept
#'  after the recodings are done. These are exempted from `cvista_only`.
#'  By default, ID columns will not be removed even when `cvista_only` is `TRUE`.
#' @rdname morph_vista
#'
#' @note
#'
#' All variables with '_c' prefix mean that they are new variables, meaning they
#' could not be fully mapped to the variable of VISTA. For example, the
#' `relationship` variable of VISTA can only be partially recreated with
#' variables from CSF2016. See `recode_cvista_relationship()` for more details.
#'
#' **Derived variables**
#' employment type fields on both data sets do not map well to each other.
#' Hence, we need to create a new employment type variable which aligns better
#' to the Census population, since it provides a lower resolution.
#' @export
morph_cvista <- function(x, cvista_only = FALSE, extra_cols = NULL) {
  checkmate::assert(
    checkmate::check_class(x, "vista1218"),
    checkmate::check_class(x, "csf2016")
  )
  checkmate::assert_data_table(x)
  checkmate::assert_flag(cvista_only)
  checkmate::assert_character(extra_cols, null.ok = TRUE)
  checkmate::assert_names(names(x), must.include = extra_cols)
  cli::cli_alert_info("Creating a copy of {.field x}")

  if (is(x, "vista1218")) {
    id_cols <- c("hhid", "persid")
  } else {
    id_cols <- csf_id_cols
  }
  extra_cols <- c(id_cols, extra_cols)
  cli::cli_alert_success(
    "Added the following ID fields {.field {id_cols}} to \\
        {.field extra_cols}."
  )

  .x <- data.table::copy(x) %>%
    recode_cvista_age(.) %>%
    recode_cvista_age5(.) %>%
    recode_cvista_sex(.) %>%
    recode_cvista_anzsco1(.) %>%
    recode_cvista_anzsic1(.) %>%
    recode_cvista_emptype(.) %>%
    recode_cvista_studying(.) %>%
    recode_cvista_relationship(.) %>%
    recode_cvista_dwelltype(.) %>%
    recode_cvista_owndwell(.) %>%
    recode_cvista_cars(.) %>%
    recode_cvista_hhinc(.)

  if (cvista_only) {
    keep_cols <- c(extra_cols, names(.x)[grepl("^cvista_", names(.x))])
    renamed_keep_cols <- gsub("^cvista_", "", keep_cols)
    cli::cli_alert_info(
      "Keeping only CVISTA columns{if(!is.null(extra_cols)){' and those in \\
            `extra_columns`'}}: {.field {keep_cols}}"
    )
    cli::cli_alert_info("Removing the 'cvista_' prefix from the newly added CVISTA columns.")
    return(
      .x[, .SD, .SDcols = keep_cols] %>%
        data.table::setnames(old = keep_cols, new = renamed_keep_cols)
    )
  }
  invisible(.x)
}

make_new_cvista_colname <- make_new_colname("cvista")

#' A factory function to create `recode_cvista_*()`
#'
#' @param .fn a function
#' @param .cols columns to use for conversion
#' @param .new_col name of the new column name
#' @param ... dots
#'
#' @export
make_recode_cvista <- function(.fn, .cols, .new_col, ...) {
  function(x, remove_cols = FALSE, ...) {
    if (!check_cols(x, .cols)) {
      # cli::cli_alert_warning("Skipping: {.field {.new_col}}")
      # warning("Skipping")
      # return(x)
    }
    cvista_new_col <- make_new_cvista_colname(.new_col)
    x <- .fn(x, cvista_new_col)
    if (!cvista_new_col %in% names(x)) {
      stop(
        "The recode function didn't create a new ",
        cvista_new_col,
        " column like it should."
      )
    }
    cli::cli_alert_success("Added: {.field {cvista_new_col}}.")
    if (remove_cols) {
      x[, c(.cols) := NULL]
      cli::cli_alert_success("Removed: {.field {.cols}}.")
    }
    return(x)
  }
}

#' Create CVISTA occupation field
#'
#' CSF2016's OCCP variable can be directly converted to
#' VISTA1218's ANZSCO1.
#'
#' @template cvistaRecode
#'
#' @export
recode_cvista_anzsco1 <- function(x, ...) {
  UseMethod("recode_cvista_anzsco1")
}

#' @export
#' @rdname recode_cvista_anzsco1
recode_cvista_anzsco1.csf2016 <-
  make_recode_cvista(recode_cvista_anzsco1_csf2016, "occp", "anzsco1")

#' @export
#' @rdname recode_cvista_anzsco1
recode_cvista_anzsco1.vista1218 <-
  make_recode_cvista(recode_cvista_anzsco1_vista, "anzsco1", "anzsco1")

recode_cvista_anzsco1_csf2016 <- function(x, new_col, ...) {
  categories_to_recode <-
    c("Inadequately described", "Not stated", "Not applicable", "Overseas visitor")
  data.table::set(x, j = new_col, value = x[["occp"]])
  x[occp %in% categories_to_recode, c(new_col) := fcase(
    occp %in% c("Not applicable", "Overseas visitor"), "Not in Work Force"
    # occp %in% c("Inadequately described", "Not stated"), NA_character_
  )]
}

recode_cvista_anzsco1_vista <- function(x, new_col, ...) {
  x[, c(new_col) := anzsco1]
  x[anzsco1 == "Missing/Refused", c(new_col) := NA_character_]
}

#' Create CVISTA industry of work field
#'
#' CSF2016's INDP variable can be directly converted to
#' VISTA1218's ANZSIC1.
#'
#'
#'
#' @template cvistaRecode
#'
#' @export
recode_cvista_anzsic1 <- function(x, ...) {
  UseMethod("recode_cvista_anzsic1")
}

#' @export
#' @rdname recode_cvista_anzsic1
recode_cvista_anzsic1.csf2016 <-
  make_recode_cvista(recode_cvista_anzsic1_csf2016, "indp", "anzsic1")

#' @export
#' @rdname recode_cvista_anzsic1
recode_cvista_anzsic1.vista1218 <-
  make_recode_cvista(recode_cvista_anzsic1_vista1218, "anzsic1", "anzsic1")

recode_cvista_anzsic1_csf2016 <- function(x, new_col, ...) {
  categories_to_recode <-
    c("Inadequately described", "Not stated", "Not applicable", "Overseas visitor")
  data.table::set(x, j = new_col, value = x[["indp"]])
  x[indp %in% categories_to_recode, c(new_col) := fcase(
    indp %in% c("Not applicable", "Overseas visitor"), "Not in Work Force"
    # indp %in% c("Inadequately described", "Not stated"), NA_character_
  )]
}

recode_cvista_anzsic1_vista1218 <- function(x, new_col, ...) {
  x[, c(new_col) := anzsic1]
  x[anzsic1 == "0", c(new_col) := NA_character_]
}


#' Create CVISTA employment type
#'
#' VISTA1218's `EMPTYPE` variable or employment type can be recreated
#' with CSF2016's SIEMP (Status in Employment).
#'
#' @template cvistaRecode
#' @note
#' If SIEMP is 'Owner with not stated employee', it will be assumed that
#' they are 'Employer'.
#' @export
recode_cvista_emptype <- function(x, ...) {
  UseMethod("recode_cvista_emptype")
}

#' @export
#' @rdname recode_cvista_emptype
recode_cvista_emptype.csf2016 <-
  make_recode_cvista(recode_cvista_emptype_csf2016, c("siemp"), "emptype")

#' @export
#' @rdname recode_cvista_emptype
recode_cvista_emptype.vista1218 <-
  make_recode_cvista(recode_cvista_emptype_vista1218, c("emptype"), "emptype")

recode_cvista_emptype_csf2016 <- function(x, new_col, ...) {
  x[, c(new_col) := fcase(
    grepl("enterprise with employees|employees not stated", siemp, ignore.case = TRUE), "Employer",
    grepl("without employees", siemp, ignore.case = TRUE), "Self-Employed",
    siemp == "Employee", "Paid Employee",
    siemp == "Contributing family worker", "Work in Family Business",
    siemp == "Not applicable", "Not in Work Force"
  )]
}

recode_cvista_emptype_vista1218 <- function(x, new_col, ...) {
  x[, c(new_col) := emptype]
}

#' Create CVISTA studying
#'
#' VISTA1218's `STUDYING` variable or "Student Status - level or none?" can be recreated
#' with CSF2016's `STUP` (Full/Part Time Student Status) and `TYPP`
#' (Type of Educational Institution Attending).
#'
#' @template cvistaRecode
#' @note
#' If SIEMP is 'Owner with not stated employee', it will be assumed that
#' they are 'Employer'.
#' @export
recode_cvista_studying <- function(x, ...) {
  UseMethod("recode_cvista_studying")
}

#' @export
#' @rdname recode_cvista_studying
recode_cvista_studying.csf2016 <-
  make_recode_cvista(recode_cvista_studying_csf2016, c("typp", "stup"), "studying")

#' @export
#' @rdname recode_cvista_studying
recode_cvista_studying.vista1218 <-
  make_recode_cvista(recode_cvista_studying_vista1218, c("studying"), "studying")

recode_cvista_studying_csf2016 <- function(x, new_col, ...) {
  typp_tafe_and_uni <- c(
    "Technical or Further Educational Institution (incl. TAFE colleges)",
    "University or other Tertiary Institutions"
  )

  x[, c(new_col) := fcase(
    grepl("Secondary", typp, ignore.case = TRUE), "Secondary",
    grepl("Infants/Primary", typp, ignore.case = TRUE), "Primary",
    typp == "Other", "Something Else",
    stup == "Full-time student" & typp %in% typp_tafe_and_uni, "Full-time TAFE/Uni",
    stup == "Part-time student" & typp %in% typp_tafe_and_uni, "Part-time TAFE/Uni",
    typp == "Not applicable", "No Study",
    typp == "Pre-school", "Something Else"
  )]
}

recode_cvista_studying_vista1218 <- function(x, new_col, ...) {
  x[, c(new_col) := studying]
}

#' Create CVISTA relationship (partial match)
#'
#' VISTA1218's `RELATIONSHIP` variable or "Relationship to Person 1" can be
#' **partially** recreated with CSF2016's `rlhp` (Relatioship in household),
#' `rpip` (Family/Household Reference Person Indicator), and `hhcd`
#' (household composition).
#'
#'
#' @template cvistaRecode
#' @export
recode_cvista_relationship <- function(x, ...) {
  UseMethod("recode_cvista_relationship")
}

#' @export
#' @rdname recode_cvista_relationship
recode_cvista_relationship.csf2016 <-
  make_recode_cvista(recode_cvista_relationship_csf2016, c("rlhp", "rpip", "hhcd"), "relationship_c")

#' @export
#' @rdname recode_cvista_relationship
recode_cvista_relationship.vista1218 <-
  make_recode_cvista(recode_cvista_relationship_vista1218, c("relationship"), "relationship_c")

recode_cvista_relationship_csf2016 <- function(x, new_col, ...) {
  categories_child <-
    c("Child under 15", "Dependent student", "Non-dependent child")
  categories_self <-
    c(
      "Reference person in primary family",
      "Reference person in a non-family household"
    )

  x[, c(new_col) := NA_character_]
  x[rpip %in% categories_self, c(new_col) := "Self"]
  x[
    rpip == "Other household member" & is.na(cvista_relationship_c),
    c(new_col) := fcase(
      rlhp %in% categories_child, "Child",
      rlhp == "Husband, Wife or Partner" & hhcd == "One family household", "Spouse",
      rlhp == "Husband, Wife or Partner" & hhcd != "One family household", "Other relative",
      rlhp == "Non-family member", "Unrelated",
      rlhp == "Other related individual", "Other relative"
    )
  ]
  x[
    rpip == "Not applicable" &
      rlhp == "Non-family member" &
      is.na(cvista_relationship_c),
    c(new_col) := "Unrelated"
  ]
  x[
    rpip == "Reference person in second or third family" &
      is.na(cvista_relationship_c),
    c(new_col) := "Other relative"
  ]
}

recode_cvista_relationship_vista1218 <- function(x, new_col, ...) {
  categories_to_recode_to_other_relative <-
    c("Grandchild", "Sibling", "Other")
  x[, c(new_col) := relationship]
  x[
    relationship %in% categories_to_recode_to_other_relative,
    c(new_col) := "Other relative"
  ]
}

#' Create CVISTA sex
#'
#' VISTA1218's `sex` variable or "Sex of person" can be
#' recreated with CSF2016's `sexp` (Sex of person).
#'
#' @template cvistaRecode
#' @export
recode_cvista_sex <- function(x, ...) {
  UseMethod("recode_cvista_sex")
}

#' @export
#' @rdname recode_cvista_sex
recode_cvista_sex.csf2016 <-
  make_recode_cvista(recode_cvista_sex_csf2016, c("sexp"), "sex")

#' @export
#' @rdname recode_cvista_sex
recode_cvista_sex.vista1218 <-
  make_recode_cvista(recode_cvista_sex_vista1218, c("sex"), "sex")

recode_cvista_sex_csf2016 <- function(x, new_col, ...) {
  x[, c(new_col) := sexp]
}

recode_cvista_sex_vista1218 <- function(x, new_col, ...) {
  x[, c(new_col) := sex]
}

#' Create CVISTA age
#'
#' VISTA1218's `age` variable or "age of person" can be
#' recreated with CSF2016's `agep` (age of person).
#'
#'
#' @template cvistaRecode
#' @export
recode_cvista_age <- function(x, ...) {
  UseMethod("recode_cvista_age")
}

#' @export
#' @rdname recode_cvista_age
recode_cvista_age.csf2016 <-
  make_recode_cvista(recode_cvista_age_csf2016, c("age5p", "agep"), "age")

#' @export
#' @rdname recode_cvista_age
recode_cvista_age.vista1218 <-
  make_recode_cvista(recode_cvista_age_vista1218, c("age"), "age")

recode_cvista_age_csf2016 <- function(x, new_col, ...) {
  if (!"age5p" %in% names(x)) {
    x <- recode_cvista_age5_csf2016(x, "age5p")
  }
  x[, c(new_col) := integerise_age5p(age5p, max_age = 90L)]
}

recode_cvista_age_vista1218 <- function(x, new_col, ...) {
  x[, c(new_col) := age]
}

integerise_age5p <- function(age5p, max_age = 85) {
  checkmate::assert_number(max_age, lower = 85)
  age5p_bounds <-
    gsub("year|years|and over|years or more", "", age5p) %>%
    trimws() %>%
    tstrsplit("-", type.convert = T) %>%
    setNames(c("lower", "upper"))
  age5p_bounds$upper[is.na(age5p_bounds$upper)] <- max_age
  # integerise age
  mapply(
    function(x, y) sample(x:y, 1),
    age5p_bounds$lower,
    age5p_bounds$upper
  )
}

#' Create CVISTA five-year age group (derived variable)
#'
#' Create a five-year age group variable using
#' VISTA1218's `age` (age of person) and CSF2016's `agep`
#' (age of person)
#'
#'
#' @template cvistaRecode
#' @export
recode_cvista_age5 <- function(x, ...) {
  UseMethod("recode_cvista_age5")
}

#' @export
#' @rdname recode_cvista_age5
recode_cvista_age5.csf2016 <-
  make_recode_cvista(recode_cvista_age5_csf2016, c("age5p", "agep"), "age5_c")

#' @export
#' @rdname recode_cvista_age5

recode_cvista_age5.vista1218 <-
  make_recode_cvista(recode_cvista_age5_vista1218, c("age"), "age5_c")

recode_cvista_age5_csf2016 <- function(x, new_col, ...) {
  if ("age5p" %in% names(x)) {
    return(x[, c(new_col) := age5p])
  }
  age_table <- make_age_table_from_csf2016_agep(x$agep, new_col)
  # preserve the original column order after the merge below
  col_order <- names(x)
  merge(x, age_table, by = "agep", sort = FALSE) %>%
    data.table::setcolorder(col_order)
}

recode_cvista_age5_vista1218 <- function(x, new_col, ...) {
  intervals <- c(seq(0, 85, 5), Inf)
  labels <- c(paste0(seq(0, 80, 5), "-", c(seq(4, 85, 5)), " years"), "85 years and over")
  x[, c(new_col) := cut(age,
    breaks = intervals,
    labels = labels,
    include.lowest = TRUE,
    right = FALSE
  )]
}

#' @param agep `agep` from csf2016
#' @param new_col name of the new five-year age group column
#' @noRd
#' @importFrom stringi stri_extract_first_regex
make_age_table_from_csf2016_agep <- function(agep, new_col) {
  data.table(
    agep = unique(agep),
    agep_lower_bound = stri_extract_first_regex(unique(agep), "[0-9]+")
  ) %>%
    .[, agep_lower_bound := as.numeric(agep_lower_bound)] %>%
    data.table::setorder("agep_lower_bound") %>%
    .[, c(new_col) := fcase(
      agep_lower_bound %in% 0:4, "0-4 years",
      agep_lower_bound %in% 5:9, "5-9 years",
      agep_lower_bound %in% 10:14, "10-14 years",
      agep_lower_bound %in% 15:19, "15-19 years",
      agep_lower_bound %in% 20:24, "20-24 years"
    )] %>%
    .[is.na(get(new_col)), c(new_col) := agep] %>%
    .[, agep_lower_bound := NULL]
}

#' Create CVISTA dwelltype
#'
#' VISTA1218's `DWELLTYPE` variable or "Dwelling type" can be
#' recreated with CSF2016's `strd` (Dwelling Structure).
#'
#'
#' @template cvistaRecode
#' @export
recode_cvista_dwelltype <- function(x, ...) {
  UseMethod("recode_cvista_dwelltype")
}

#' @export
#' @rdname recode_cvista_dwelltype
recode_cvista_dwelltype.csf2016 <-
  make_recode_cvista(recode_cvista_dwelltype_csf2016, c("strd"), "dwelltype")

#' @export
#' @rdname recode_cvista_dwelltype
recode_cvista_dwelltype.vista1218 <-
  make_recode_cvista(recode_cvista_dwelltype_vista1218, c("dwelltype"), "dwelltype")

recode_cvista_dwelltype_csf2016 <- function(x, new_col, ...) {
  x[, c(new_col) := fcase(
    strd == "Separate house", "Separate House",
    strd == "Semi-detached, row or terrace house, townhouse, etc.",
    "Terrace/Townhouse",
    strd == "Flat or apartment", "Flat or Apartment",
    strd == "Not stated", NA_character_,
    strd == "Other dwelling", "Other"
  )]
}

recode_cvista_dwelltype_vista1218 <- function(x, new_col, ...) {
  x[, c(new_col) := dwelltype]
  x[dwelltype == "Missing", c(new_col) := NA_character_]
}

#' Create CVISTA owndwell (partial match)
#'
#' VISTA1218's `OWNDWELL` variable or "Dwelling ownership" can be
#' recreated with CSF2016's `tend` (Tenure Type).
#'
#'
#' @template cvistaRecode
#' @export
recode_cvista_owndwell <- function(x, ...) {
  UseMethod("recode_cvista_owndwell")
}

#' @export
#' @rdname recode_cvista_owndwell
recode_cvista_owndwell.csf2016 <-
  make_recode_cvista(recode_cvista_owndwell_csf2016, c("tend"), "owndwell_c")

#' @export
#' @rdname recode_cvista_owndwell
recode_cvista_owndwell.vista1218 <-
  make_recode_cvista(recode_cvista_owndwell_vista1218, c("owndwell"), "owndwell_c")

recode_cvista_owndwell_csf2016 <- function(x, new_col, ...) {
  x[
    ,
    c(new_col) := fcase(
      tend == "Owned outright", "Fully Owned",
      tend == "Owned with a mortgage (includes being purchased under a rent/buy scheme)",
      "Being Purchased",
      tend == "Rented (includes being occupied rent free)",
      "Rented (includes being occupied rent free)",
      tend == "Other (includes being occupied under life tenure scheme)",
      "Something Else"
    )
  ]
}

recode_cvista_owndwell_vista1218 <- function(x, new_col, ...) {
  x[, c(new_col) := owndwell]
  x[
    owndwell %in% c("Being Rented", "Occupied Rent-Free"),
    c(new_col) := "Rented (includes being occupied rent free)"
  ]
}

#' Create CVISTA cars (partial match)
#'
#' VISTA1218's `CARS` variable or "Number of cars" can be
#' **partially** recreated with CSF2016's `vehrd` (number of vehicles).
#'
#'
#' @template cvistaRecode
#' @export
recode_cvista_cars <- function(x, ...) {
  UseMethod("recode_cvista_cars")
}

#' @export
#' @rdname recode_cvista_cars
recode_cvista_cars.csf2016 <-
  make_recode_cvista(recode_cvista_cars_csf2016, c("vehrd"), "cars_c")

#' @export
#' @rdname recode_cvista_cars
recode_cvista_cars.vista1218 <-
  make_recode_cvista(recode_cvista_cars_vista1218, c("cars"), "cars_c")

recode_cvista_cars_csf2016 <- function(x, new_col, ...) {
  x[
    ,
    c(new_col) := fcase(
      vehrd == "No motor vehicles", "0",
      vehrd == "One motor vehicle", "1",
      vehrd == "Two motor vehicles", "2",
      vehrd == "Three motor vehicles", "3",
      vehrd == "Four or more motor vehicles", "4+"
    )
  ]
}

recode_cvista_cars_vista1218 <- function(x, new_col, ...) {
  x[, c(new_col) := as.character(cars)]
  x[cars >= 4, c(new_col) := "4+"]
}

#' Create CVISTA hhinc (derived variable)
#'
#' VISTA1218's `HHINC` variable or "Household income" can be
#' used to recreate with CSF2016's `rlhp` (Relatioship in household)
#' and `rpip` (Family/Household Reference Person Indicator).
#'
#'
#' @template cvistaRecode
#' @note
#'
#' "Negative income" in CSF2016 will be recoded as "Nil income" as
#' `hhinc` in VISTA1218 doesn't contain negative income.
#' @export
recode_cvista_hhinc <- function(x, ...) {
  UseMethod("recode_cvista_hhinc")
}

#' @export
#' @rdname recode_cvista_hhinc
recode_cvista_hhinc.csf2016 <-
  make_recode_cvista(recode_cvista_hhinc_csf2016, c("hind"), "hhinc_c")

#' @export
#' @rdname recode_cvista_hhinc
recode_cvista_hhinc.vista1218 <-
  make_recode_cvista(recode_cvista_hhinc_vista1218, c("hhinc"), "hhinc_c")

recode_cvista_hhinc_csf2016 <- function(x, new_col, ...) {
  x[, c(new_col) := hind]
  x[get(new_col) == "Negative income", c(new_col) := "Nil income"]
  x[
    get(new_col) %in% c("Partial income stated", "All incomes not stated"),
    c(new_col) := NA
  ]
}

recode_cvista_hhinc_vista1218 <- function(x, new_col, ...) {
  csf2016_hind_interval <-
    c(
      0, 1, 150, 300, 400, 500, 650, 800, 1000,
      1250, 1500, 1750, 2000, 2500, 3000, 3500,
      4000, 4500, 5000, 6000, 8000, Inf
    )
  names(csf2016_hind_interval) <- c(
    "Nil income",
    "$1-$149 ($1-$7,799)",
    "$150-$299 ($7,800-$15,599)",
    "$300-$399 ($15,600-$20,799)",
    "$400-$499 ($20,800-$25,999)",
    "$500-$649 ($26,000-$33,799)",
    "$650-$799 ($33,800-$41,599)",
    "$800-$999 ($41,600-$51,999)",
    "$1,000-$1,249 ($52,000-$64,999)",
    "$1,250-$1,499 ($65,000-$77,999)",
    "$1,500-$1,749 ($78,000-$90,999)",
    "$1,750-$1,999 ($91,000-$103,999)",
    "$2,000-$2,499 ($104,000-$129,999)",
    "$2,500-$2,999 ($130,000-$155,999)",
    "$3,000-$3,499 ($156,000-$181,999)",
    "$3,500-$3,999 ($182,000-$207,999)",
    "$4,000-$4,499 ($208,000-$233,999)",
    "$4,500-$4,999 ($234,000-$259,999)",
    "$5,000-$5,999 ($260,000-$311,999)",
    "$6,000-$7,999 ($312,000-$415,999)",
    "$8,000 or more ($416,000 or more)"
  )

  if (is.character(x$hhinc)) {
    cli::cli_alert_info("Converting {.field hhinc} from character to numeric.")
    x[, hhinc := gsub("\\$|,", "", hhinc) %>% as.numeric()]
  }

  x[, c(new_col) := cut(hhinc,
    breaks = csf2016_hind_interval,
    include.lowest = TRUE,
    right = FALSE,
    labels = names(csf2016_hind_interval)[1:(length(csf2016_hind_interval) - 1)]
  )]
}

#' Create CVISTA household type (hhtype_c)
#'
#' A simplified household type can be created with VISTA1218's `RELATIONSHIP`
#' variable or "Relationship to Person 1" and CSF2016's `rlhp` (Relatioship in household)
#' and `rpip` (Family/Household Reference Person Indicator).
#'
#'
#' @template cvistaRecode
recode_cvista_hhtype <- function(x, ...) {
  UseMethod("recode_cvista_hhtype")
}

#' @rdname recode_cvista_hhtype
recode_cvista_hhtype.csf2016 <-
  make_recode_cvista(recode_cvista_hhtype_csf2016, c("fmcf"), "hhtype")

#' @rdname recode_cvista_hhtype
recode_cvista_hhtype.vista1218 <-
  make_recode_cvista(recode_cvista_hhtype_vista1218, c("relationship"), "hhtype")

recode_cvista_hhtype_csf2016 <- function(x, new_col, ...) {
  x
}

recode_cvista_hhtype_vista1218 <- function(x, new_col, ...) {
  stop("Not implemented yet.")
  #  hhtypes <- x %>%
  #     mutate(relationship = ifelse(persno == 1, "Self", relationship)) %>%
  #     count(hhid, relationship) %>%
  #     spread(relationship, n) %>%
  #     replace(is.na(.), 0) %>%
  #     mutate(total_members = rowSums(across(where(is.numeric)))) %>%
  #     mutate(
  #         hhtype = case_when(
  #             total_members == 1 ~ "Lone",
  #             total_members == 2 & spouse == 1 ~ "couple_wo_children",
  #             total_members > 2 & spouse == 1 & child != 0 ~ "couple_w_children",
  #             total_members != 1 & spouse == 0 & child != 0 ~ "lone_parent",
  #             TRUE ~ as.character("others")
  #         )
  #     )

  # merge(df, hhtypes %>% select(hhid, hhtype), by = "hhid")
}
