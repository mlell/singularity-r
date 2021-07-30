#!/usr/bin/env bash
#
# Build the Singularity container
set -ue

singularity build -F r-py.sif Singularity-r
singularity build -F rstudio.sif Singularity-rstudio
