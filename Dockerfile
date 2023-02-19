FROM rocker/r-ver:4.2.0
RUN apt-get -y update && apt-get install -y libssl-dev \
    libxml2-dev \
    # sf dependencies
    libudunits2-dev libgdal-dev libgeos-dev libproj-dev

RUN mkdir /usr/src/module 
WORKDIR /usr/src/module
ADD . .

RUN R -e "install.packages('pak', type = 'source')"
RUN R -e "pak::local_install()"

CMD ["R", "-e", "PopulationSynthesiser::run_workflow('/atrc_data/parameters.yaml')"]