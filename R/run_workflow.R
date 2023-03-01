#' Run the ATRC workflow
#'
#' This workflow creates a synthetic population from a reference sample
#' and control data as specified in the input config file. The fitting and
#' replicating algorithms can also be selected in the config file.
#'
#' @param config_path path to an ATRC workflow config file.
#'  See the expected format at <https://github.com/ATRC-AURIN/PopulationSynthesiser/blob/main/atrc_workflow/parameters.yaml>.
#' @return a list of `mlfit`'s fitted problem and a `data.frame`
#'  of the resulting synthetic population.
#' @importFrom yaml read_yaml
#' @importFrom mlfit ml_problem ml_fit ml_replicate
#'
#' @export
run_workflow <- function(config_path = "/atrc_data/parameters.yaml") {
  cli::cli_progress_step("Checking the config file.")
  config <- checkmate::assert_file_exists(config_path) %>%
    yaml::read_yaml()

  cli::cli_progress_step("Checking the reference sample.")
  ref_sample <- checkmate::assert_file_exists(config$inputs$REFERENCE_SAMPLE$path) %>%
    read.csv()

  cli::cli_progress_step("Checking the control files.")
  p_ctrls <- purrr::map(
    .x = config$inputs$PERSONS_CONTROL$path,
    .f = ~ checkmate::assert_file_exists(.x) %>% data.table::fread()
  )
  h_ctrls <- purrr::map(
    .x = config$inputs$HOUSEHOLDS_CONTROL$path,
    .f = ~ checkmate::assert_file_exists(.x) %>% data.table::fread()
  )

  cli::cli_progress_step("Creating a fitting problem.")
  fitting_problem <- ml_problem(
    ref_sample = ref_sample,
    individual_controls = p_ctrls,
    group_controls = h_ctrls,
    field_names = special_field_names(
      groupId = config$inputs$GROUP_ID$value,
      individualId = config$inputs$INDIVIDUAL_ID$value,
      count = config$inputs$COUNT$value
    )
  )

  cli::cli_progress_step("Fitting the fitting problem.")
  fitted_problem <- ml_fit(
    fitting_problem,
    algorithm = config$inputs$ML_FIT_ALGORITHM$value
  )

  cli::cli_progress_step("Replicating the calibrated reference sample.")
  synthetic_population <- ml_replicate(
    fitted_problem,
    algorithm = config$inputs$ML_REPLICATE_ALGORITHM$value
  )

  outfile <- fs::path(
    config$inputs$OUTPUT_DIRECTORY$value,
    config$inputs$SYNTHETIC_POPULATION_FILENAME$value
  )

  print(config)
  print(outfile)

  cli::cli_progress_step("Writing the synthetic population to a CSV file: : {.path {outfile}}.")
  checkmate::assert_directory_exists(dirname(outfile))
  write.csv(synthetic_population, outfile)

  cli::cli_progress_step("Returning the results.")
  invisible(list(
    fitted_problem = fitted_problem,
    synthetic_population = synthetic_population
  ))
}

rw <- function() {
  run_workflow("atrc_workflow/local_parameters.yaml")
}
