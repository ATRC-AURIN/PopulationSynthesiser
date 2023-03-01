#' Run the ATRC workflow
#'
#' This workflow creates a synthetic population from a reference sample
#' and control data as specified in the input config file. The fitting and
#' replicating algorithms can also be selected in the config file.
#'
#' @param config_path path to an ATRC workflow config file.
#'  See the Details section below for the expected format.
#' @return a list of `mlfit`'s fitted problem and a `data.frame`
#'  of the resulting synthetic population.
#' @importFrom yaml read_yaml
#' @importFrom mlfit ml_problem ml_fit ml_replicate
#'
#' @details
#'
#' Here is the expected format of a config file.
#'
#' ```yaml
#' inputs:
#'   REFERENCE_SAMPLE:
#'     description: The reference sample to use for the synthetic population.
#'     type: path
#'     path: atrc_data/inputs/reference_sample.csv
#'   PERSONS_CONTROL:
#'     description: "The person-level control files."
#'     type: multiple_paths
#'     path:
#'       - atrc_data/inputs/persons-control1.csv
#'       - atrc_data/inputs/persons-control2.csv
#'   HOUSEHOLDS_CONTROL:
#'     description: "The household-level control files."
#'     type: multiple_paths
#'     path:
#'       - atrc_data/inputs/households-control1.csv
#'       - atrc_data/inputs/households-control2.csv
#'   GROUP_ID:
#'     description: The group ID column of the reference sample.
#'     type: value
#'     value: "hhid"
#'   INDIVIDUAL_ID:
#'     description: The individual ID column of the reference sample.
#'     type: value
#'     value: "persid"
#'   COUNT:
#'     description: |
#'       Name of the control total column in control tables.
#'     type: value
#'     value: "n"
#'   ML_FIT_ALGORITHM:
#'     description: |
#'       The algorithm to use for fitting the synthetic population. 
#'       See the available algorithms at https://mlfit.github.io/mlfit/reference/ml_fit.html.
#'     type: value
#'     value: "ipu"
#'   ML_REPLICATE_ALGORITHM:
#'     description: |
#'       The algorithm to use for replicating the synthetic population.
#'       See the available algorithms at https://mlfit.github.io/mlfit/reference/ml_replicate.html.
#'     type: value
#'     value: "trs"
#' outputs:
#'   OUTPUT_DIRECTORY:
#'     description: The path where the output files will be saved.
#'     type: path
#'     path: atrc_data/outputs
#'   SYNTHETIC_POPULATION_FILENAME:
#'     description: The path where the synthetic population will be saved as.
#'     type: string
#'     value: synthetic_population.csv
#' ```
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

  cli::cli_progress_step("Writing the synthetic population to a CSV file: : {.path {config$outputs$SYNTHETIC_POPULATION$path}}.")
  checkmate::assert_directory_exists(dirname(config$outputs$SYNTHETIC_POPULATION$path))
  write.csv(synthetic_population, config$outputs$SYNTHETIC_POPULATION$path)

  cli::cli_progress_step("Returning the results.")
  invisible(list(
    fitted_problem = fitted_problem,
    synthetic_population = synthetic_population
  ))
}

rw <- function() {
  run_workflow("atrc_workflow/local_parameters.yaml")
}
