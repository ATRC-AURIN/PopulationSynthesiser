#' Create a toy synthetic population using CSF 2016
#'
#' @description
#'
#' This function is for internal testing of the package and also
#' serves as a minimum example.
#'
#' @param toy_data a `list()` of `data.table()`s that will be used
#'  to create a toy fitting problem.
#' @param fitting_algorithms `character()` one or more of these options:
#'  "entropy_o", "dss", "ipu", "hipf".
#'
#' @return a list of fitting results.
#' @noRd
#'
#' @examples
#'
#' if (FALSE) {
#'   create_toy_population()
#' }
create_toy_population <-
  function(toy_data,
           fitting_algorithms = "ipu") {
    checkmate::assert_subset(
      fitting_algorithms,
      .fitting_algorithms,
      empty.ok = FALSE
    )

    geo_hierarchy <-
      merge(
        census_2016_dictionary$place_of_usual_residence[, sa4_code_2016 := as.integer(sa4_code_2016)],
        census_2016_dictionary$statistical_areas[, sa4_code_2016 := as.integer(sa4_code_2016)],
        by = "sa4_code_2016"
      ) %>%
      .[, .(regucp = csf_code, sa2 = sa2_code_2016)]

    fitting_problems <- ml_problem(
      ref_sample = toy_data$microdata,
      field_names = special_field_names(
        groupId = "abshid", individualId = "abspid", count = "count",
        zone = "sa2", region = "regucp"
      ),
      group_controls = toy_data$household_control_tables,
      individual_controls = toy_data$person_control_tables,
      geo_hierarchy = geo_hierarchy
    )
    toy_problem <- fitting_problems[[1]]

    toy_fits <-
      lapply(
        fitting_algorithms,
        function(x) {
          ml_fit(algorithm = x, toy_problem)
        }
      ) %>% setNames(fitting_algorithms)
  }

#' Load toy data
#' @description
#' Create a list of toy data
#' @param n_microdata `integer(1)` number of households from the test microdata.
#'  If `NULL` then load all.
#' @param microdata_zone_field either `areaenum` or `regucp`.
#' @param n_zones `integer(1)` number of zones from the control tables. If `NULL` then load
#' all.
#' @param n_person_tables `integer(1)` number of person tables to be created.
#' @param n_household_tables `integer(1)` number of household tables to be created.
#'
#' @noRd
#' @return a named `list()` of `data.table::data.table()`s.
load_toy_data <-
  function(n_microdata = 500,
           microdata_zone_field = "areaenum",
           n_zones = 1,
           n_person_tables = 1,
           n_household_tables = 1) {
    checkmate::assert(
      checkmate::check_count(n_microdata, positive = TRUE, null.ok = TRUE),
      checkmate::check_count(n_zones, positive = TRUE, null.ok = TRUE),
      checkmate::check_count(n_person_tables, positive = TRUE),
      checkmate::check_count(n_household_tables, positive = TRUE),
      combine = "and"
    )

    csf_filenames <-
      c("BCSF16_person_new", "BCSF16_family", "BCSF16_dwelling")

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

    microdata <- read_census_microdata(
      census_microdata_2016_paths$person,
      census_microdata_2016_paths$family,
      census_microdata_2016_paths$dwelling,
      census_year = "2016",
      select = c(microdata_zone_field, "agep", "mstp", "sexp", "nprd")
    )

    # select only a small subset of the population
    if (!is.null(n_microdata)) {
      microdata <-
        microdata[abshid %in% (microdata[["abshid"]] %>% sample(n_microdata, replace = FALSE)), ]
    }

    select_sa2 <- function(x, n_zones) {
      if (!is.null(n_zones)) {
        return(x[sa2 %in% x[, sample(unique(sa2), n_zones)]])
      }
      x
    }

    replicate_table <- function(x, times) {
      rep(list(x), times)
    }

    person_control_tables <-
      system.file(
        "testdata",
        "2016-nsw-sa2-ur-sex-mstp.csv",
        package = "PopulationSynthesiser"
      ) %>%
      read_census_tablebuilder(simplify_names = TRUE) %>%
      create_fitting_control() %>%
      select_sa2(n_zones = n_zones) %>%
      replicate_table(times = n_person_tables)

    household_control_tables <-
      system.file(
        "testdata",
        "2016-nsw-sa2-dwelling-nprd.csv",
        package = "PopulationSynthesiser"
      ) %>%
      read_census_tablebuilder(simplify_names = TRUE) %>%
      create_fitting_control() %>%
      .[sa2 %in% unique(person_control_tables[[1]]$sa2), ] %>%
      replicate_table(times = n_household_tables)

    list(
      microdata = microdata,
      person_control_tables = person_control_tables,
      household_control_tables = household_control_tables
    )
  }

.create_toy_problem <- function(n_microdata = 500, zone = NULL, n_person_tables = 1,
                                n_household_tables = 1) {
  toy_data <-
    load_toy_data(
      n_microdata = n_microdata,
      n_person_tables = n_person_tables,
      n_household_tables = n_household_tables,
      microdata_zone_field = "regucp",
      n_zones = NULL # load all zones
    )

  geo_hierarchy <-
    csf_geo2016()

  fitting_problems <- ml_problem(
    ref_sample = toy_data$microdata,
    field_names = special_field_names(
      groupId = "abshid", individualId = "abspid", count = "count",
      zone = "sa2", region = "regucp"
    ),
    group_controls = toy_data$household_control_tables,
    individual_controls = toy_data$person_control_tables,
    geo_hierarchy = geo_hierarchy
  )

  toy_zone <- ifelse(!is.null(zone), zone, names(fitting_problems)[1])

  fp <- fitting_problems[[toy_zone]]

  if (is.null(fp)) {
    stop("`zone` not found.")
  }

  fp
}
