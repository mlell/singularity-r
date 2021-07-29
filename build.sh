#!/usr/bin/env bash
#
# Build the Singularity container

singularity build r-py.sif Singularity-r
singularity build rstudio.sif Singularity-rstudio
