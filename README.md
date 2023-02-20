
<!-- README.md is generated from README.Rmd. Please edit that file -->

# PopulationSynthesiser

<!-- badges: start -->

[![ATRC](https://img.shields.io/badge/ATRC-RCITI-blue.svg?logo=data:image/svg+xml;base64,PHN2ZyBpZD0iTGF5ZXJfMSIgZGF0YS1uYW1lPSJMYXllciAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAzMTcuNTMgMzE3LjUzIj48ZGVmcz48c3R5bGU+LmNscy0xe2ZpbGw6I2FmNzliNDt9LmNscy0ye2ZpbGw6I2Y2OGU0OTt9LmNscy0ze2ZpbGw6I2VmM2Y2MTt9LmNscy00e2ZpbGw6IzdmZDBkYjt9PC9zdHlsZT48L2RlZnM+PHJlY3QgY2xhc3M9ImNscy0xIiB5PSIxNDAuMzMiIHdpZHRoPSIzMTcuNTMiIGhlaWdodD0iMzYuODciLz48cmVjdCBjbGFzcz0iY2xzLTEiIHg9IjI3My4wMyIgeT0iMjczLjAzIiB3aWR0aD0iMzYuODciIGhlaWdodD0iMzYuODciIHRyYW5zZm9ybT0idHJhbnNsYXRlKC0xMjAuNzMgMjkxLjQ2KSByb3RhdGUoLTQ1KSIvPjxyZWN0IGNsYXNzPSJjbHMtMSIgeD0iNy42NCIgeT0iNy42NCIgd2lkdGg9IjM2Ljg3IiBoZWlnaHQ9IjM2Ljg3IiB0cmFuc2Zvcm09InRyYW5zbGF0ZSgtMTAuOCAyNi4wNykgcm90YXRlKC00NSkiLz48cmVjdCBjbGFzcz0iY2xzLTIiIHg9IjE0MC4zMyIgd2lkdGg9IjM2Ljg3IiBoZWlnaHQ9IjMxNy41MyIvPjxyZWN0IGNsYXNzPSJjbHMtMiIgeD0iNy42NCIgeT0iMjczLjAzIiB3aWR0aD0iMzYuODciIGhlaWdodD0iMzYuODciIHRyYW5zZm9ybT0idHJhbnNsYXRlKC0xOTguNDYgMTAzLjgpIHJvdGF0ZSgtNDUpIi8+PHJlY3QgY2xhc3M9ImNscy0yIiB4PSIyNzMuMDMiIHk9IjcuNjQiIHdpZHRoPSIzNi44NyIgaGVpZ2h0PSIzNi44NyIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoNjYuOTMgMjEzLjczKSByb3RhdGUoLTQ1KSIvPjxyZWN0IGNsYXNzPSJjbHMtMyIgeD0iMTQwLjMzIiB5PSIyNi40MiIgd2lkdGg9IjM2Ljg3IiBoZWlnaHQ9IjI2NC43IiB0cmFuc2Zvcm09InRyYW5zbGF0ZSgtNjUuNzYgMTU4Ljc3KSByb3RhdGUoLTQ1KSIvPjxyZWN0IGNsYXNzPSJjbHMtNCIgeD0iMjYuNDIiIHk9IjE0MC4zMyIgd2lkdGg9IjI2NC43IiBoZWlnaHQ9IjM2Ljg3IiB0cmFuc2Zvcm09InRyYW5zbGF0ZSgtNjUuNzYgMTU4Ljc3KSByb3RhdGUoLTQ1KSIvPjwvc3ZnPg==)](https://github.com/asiripanich/aurin)
[![R-CMD-check](https://github.com/ATRC-AURIN/PopulationSynthesiser/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ATRC-AURIN/PopulationSynthesiser/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

This package offers functions to create synthetic populations using data
from the Australian Bureau of Statistics (ABS). It utilises the
multi-level proportional fitting and replication implementations from
mlfit. Key features for ABS data include:

- Matching variables between the 1% Census Sample Files for 2011 and
  2016 to ABS’s TableBuilder control tables.
- Linking parent-child relationships between family members in
  households.
- Generating a population by zone.

Synthetic populations are crucial inputs for agent-based microsimulation
models. To generate a synthetic population, a reference sample and
population margins are required. Calibrating the reference sample to
match population margins using techniques such as Iterative Proportion
Fitting and integerising the calibrated weights determine the number of
clones required to mimic the real population.

## Installation

You can install the released version of PopulationSynthesiser from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("AURIN-OFFICE/PopulationSynthesiser", ref = remotes::github_release())
```

Or the latest development version with:

``` r
remotes::install_github("AURIN-OFFICE/PopulationSynthesiser")
```

# Why Synthesize a Population?

In an ideal world, all data would be freely accessible without fear of
privacy violations. However, this is not yet the case, and sensitive
information such as unit record data from census surveys is often
restricted from public use. This means that researchers and planners are
missing out on valuable information about the population at a unit
record level, which could help solve pressing social issues such as
employment, demographics, and transportation.

Population synthesis provides a solution to this problem by
reconstructing the full population data using only a sample of the data
and some observed margins of the population. This technique is
increasingly used in microsimulation and agent-based simulation, which
are important tools in travel demand forecasting studies. The resulting
synthetic population provides detailed information about people and
households that can support a range of applications.

## Get started

We provide an example of how to use the package to generate a synthetic
population for the \`Randwick - North’ region, New South Wales. This
example is divided into two parts:

1.  `vignette(data-preparation)` provides step-by-step instructions how
    to download microdata and control tables from ABS data portals.
2.  `vignette(get-started)` provides step-by-step instructions how to
    generate a synthetic population using this package.

## Developer notes

### Installation

This project is being developed on VSCode and we are using [the Visual
Studio Code Remote - Containers
extension](https://code.visualstudio.com/docs/remote/containers) to
create a reproducible development environment.

The easiest option would be to clone this repository and use the much
loved [RStudio IDE](https://www.rstudio.com/products/rstudio/). However,
if you fancy VSCode (like myself) then follow the instruction below.

To start developing:

1)  Install the Visual Studio Code IDE (If you have read through to
    here, I bet you already have it on your machine ;)).
2)  Install the Visual Studio Code Remote - Containers extension. Search
    for `ms-vscode-remote.remote-containers` in the extensions tab.
3)  Bring up the VSCode command pallete by typing `ctrl+shift+p` (on
    Window and Linux) or `cmd+shift+p` (on MacOS).
4)  Select `Remote-Containers: Reopen in Container`. During this stage
    the docker development container as defined in
    `.devcontainer/Dockerfile` and `.devcontainer/devcontainer.json`
    will be built and once it is created the VSCode terminal will be
    connected to the container.
