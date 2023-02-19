csf_fitting_problem <- function(csf_year, all = FALSE) {
  checkmate::assert_number(csf_year)
  if (csf_year == 2011) {
    return(csf2011_fitting_problem(all = all))
  }
  if (csf_year == 2016) {
    return(csf2016_fitting_problem(all = all))
  }
  stop("Unknown csf_year")
}

csf_fitting_problem2 <- function(microdata, geo_hierarchy, all = FALSE) {
  person_control_1 <-
    read_census_tablebuilder(here::here("inst/testdata/2016-nsw-sa2-ur-sex-mstp.csv")) %>%
    create_fitting_control()

  person_control_2 <-
    read_census_tablebuilder(here::here("inst/testdata/2016-nsw-sa2-ur-occp.csv")) %>%
    create_fitting_control()

  household_control_1 <-
    read_census_tablebuilder(here::here("inst/testdata/2016-nsw-sa2-dwelling-nprd.csv")) %>%
    create_fitting_control()

  fitting_problems <- ml_problem(
    ref_sample = microdata,
    field_names = special_field_names(
      groupId = "abshid", individualId = "abspid", count = "count",
      zone = "sa2", region = "regucp"
    ),
    group_controls = list(household_control_1),
    individual_controls = list(person_control_1, person_control_2),
    geo_hierarchy = geo_hierarchy
  )

  if (isTRUE(all)) {
    fitting_problems
  }

  fitting_problems[[1]]
}

csf2016_fitting_problem <- function(all) {
  csf_fitting_problem2(load_csf2016(), csf_geo2016(), all)
}

csf2011_fitting_problem <- function(all) {
  csf_fitting_problem2(csf2011_microdata(), csf_geo2011(), all)
}

csf2011_microdata <- function() {
  csf_folder_dir <-
    here::here("inst", "testdata", "confidential", "Census2011_CSV")
  microdata <-
    read_census_microdata(
      person_file = fs::path(csf_folder_dir, "CSF11BP.csv"),
      family_file = fs::path(csf_folder_dir, "CSF11BF.csv"),
      dwelling_file = fs::path(csf_folder_dir, "CSF11BD.csv"),
      census_year = 2011,
      select = c("regucp", "agep", "mstp", "sexp", "nprd", "occp", "rlhp")
    ) %>%
    create_fitting_sample()
}

paths_to_csf2016 <- function() {
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
}

load_csf2016 <- function() {
  census_microdata_2016_paths <- paths_to_csf2016()
  microdata <- read_census_microdata(
    census_microdata_2016_paths$person,
    census_microdata_2016_paths$family,
    census_microdata_2016_paths$dwelling,
    census_year = "2016"
  )
}
