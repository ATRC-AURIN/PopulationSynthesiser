FROM rocker/r-ver:4.2
RUN apt-get update && apt-get install -y  gdal-bin libcurl4-openssl-dev libgdal-dev libgeos-dev libgeos++-dev libicu-dev libproj-dev libssl-dev libudunits2-dev libxml2-dev make pandoc zlib1g-dev && rm -rf /var/lib/apt/lists/*
RUN mkdir /usr/src/module 
WORKDIR /usr/src/module

RUN Rscript -e 'install.packages("remotes")'
RUN Rscript -e 'remotes::install_version("glue",upgrade="never", version = "1.6.2")'
RUN Rscript -e 'remotes::install_version("cli",upgrade="never", version = "3.6.0")'
RUN Rscript -e 'remotes::install_version("magrittr",upgrade="never", version = "2.0.3")'
RUN Rscript -e 'remotes::install_version("stringi",upgrade="never", version = "1.7.12")'
RUN Rscript -e 'remotes::install_version("R6",upgrade="never", version = "2.5.1")'
RUN Rscript -e 'remotes::install_version("fs",upgrade="never", version = "1.6.1")'
RUN Rscript -e 'remotes::install_version("rmarkdown",upgrade="never", version = "2.18")'
RUN Rscript -e 'remotes::install_version("knitr",upgrade="never", version = "1.42")'
RUN Rscript -e 'remotes::install_version("yaml",upgrade="never", version = "2.3.7")'
RUN Rscript -e 'remotes::install_version("sf",upgrade="never", version = "1.0-9")'
RUN Rscript -e 'remotes::install_version("purrr",upgrade="never", version = "1.0.1")'
RUN Rscript -e 'remotes::install_github("mlfit/mlfit",upgrade="never", version = "0.6.1.9001")'
RUN Rscript -e 'remotes::install_version("checkmate",upgrade="never", version = "2.1.0")'
RUN Rscript -e 'remotes::install_version("data.table",upgrade="never", version = "1.14.6")'
RUN Rscript -e 'remotes::install_version("mapview",upgrade="never", version = "2.11.0")'
RUN Rscript -e 'remotes::install_version("janitor",upgrade="never", version = "2.1.0")'
RUN Rscript -e 'remotes::install_version("readxl",upgrade="never", version = "1.4.1")'
RUN Rscript -e 'remotes::install_version("covr",upgrade="never", version = "3.6.1")'
RUN Rscript -e 'remotes::install_version("here",upgrade="never", version = "1.0.1")'
RUN Rscript -e 'remotes::install_version("testthat",upgrade="never", version = "3.1.5")'

ADD . .

RUN R -e 'remotes::install_local(upgrade="never")'

CMD ["R", "-e", "PopulationSynthesiser::run_workflow('/atrc_data/parameters.yaml')"]