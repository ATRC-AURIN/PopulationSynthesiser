#!/bin/bash

# Build the container image.
docker build \
    --progress plain \
    -t popsyn .

# Force copy over parameters.
cp -f atrc_workflow/parameters.yaml atrc_data/parameters.yaml

# Run the container.
docker run \
    --mount type=bind,source="$(pwd)"/atrc_data,target=/atrc_data \
    popsyn
    