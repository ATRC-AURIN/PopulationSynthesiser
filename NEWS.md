<!-- NEWS.md is maintained by https://cynkra.github.io/fledge, do not edit -->

# PopulationSynthesiser 0.2.2.9001 (2023-02-11)

- Updated README.
- The pkgdown documentation site now has an article section with two vignettes about data preparation and get started.
- Install `mlfit` from its GitHub repo instead of CRAN to keep up with latest updates. 


# PopulationSynthesiser 0.2.2.9000 (2023-02-02)

- Update README.
- Fix failed tests.


# PopulationSynthesiser 0.2.2 (2022-03-30)

- Use pak to install the package during Docker build.
- Fixed #26.

# PopulationSynthesiser 0.2.1 (2022-03-20)

- Upgrade Pkgdown's to Boostrap 5.
- Introduce ATRC workflow.


# PopulationSynthesiser 0.2.0 (2022-01-04)

- Make `census_2011_dictionary` more similar to `census_2016_dictionary`. `AGEP` in the person table has been expanded and the column names across the microdata tables are identical in the two dictionaries.
- `read_census_microdata()` now assigns unique family and person ids to all individuals in CSF 2011.
- Removed `FittingProblemGenerator`, the same result can already be achieved using `mlfit::ml_problem()`.
- Added `postfit_add_relationships()` (ATRC-73).
- Added `prefit_csf_agep_to_age5p()` for recategorising CSF's age of person (agep) to five-year age groups.
- Added `postfit_integerise_age5p()` for disaggregating 5-year age groups to single year of age.
- Added `prefit_control_retotal()` for redistributing a new grand total to the control tables of an `ml_problem` object.
- `scripts/run_example.R` now reads all control files that match the Regular expression patterns. Any file that matches 'persons-control*.\\.csv' will be used as a person control, and 'households-control*.\\.csv' as a household control.


# PopulationSynthesiser 0.1.1.9004 (2021-08-16)

- Change the Dockerfile to run in the detech mode


# PopulationSynthesiser 0.1.1.9003 (2021-08-16)

- Dockerfile now runs the example script


# PopulationSynthesiser 0.1.1.9002 (2021-08-16)

- The package now uses the CRAN version of mlfit.


# PopulationSynthesiser 0.1.1.9001 (2021-08-10)

- Automate Docker image building and uploading using GitHub Actions.


# PopulationSynthesiser 0.1.1.9000 (2021-06-25)

- Add `morph_cvista()`, a function that creates a Close enough to VISTA population from VISTA 2012-2018 and Census CSF 2016 populations. This is requires for creating an input population for the ATRC activity generator.
- Bundle the VISTA 2012-2018 public version with the package and can be accessed by calling `vista1218web`.
- Use `cli` package for printing pretty messages.


# PopulationSynthesiser 0.1.1 (2021-06-17)

- Replace the `MultiLevelIPF` package with the `mlfit` package, the same package with a brand new name (ATRC-84).
- Replace the deprecated `fitting_problem()` function with `ml_problem()` (ATRC-83).


# PopulationSynthesiser 0.1.0 (2021-04-01)

* Initial release.
