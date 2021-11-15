#!/usr/bin/env bash
#
# Build the Singularity container
set -ue

if [ -z "${DEBUG-}" ]; then
  # make sure it doesn't fail
  git status -s &>/dev/null
  if [ ! "$(git status -s | wc -l)" = "0" ]; then
    echo "Working dir dirty!" >&2
    exit 1
  fi 
fi

if [ ! -f debian-baseimage.sif ]; then 
  singularity build -F debian-baseimage.sif Singularity-baseimage
fi
singularity build -F r-py.sif Singularity-r
singularity build -F rstudio.sif Singularity-rstudio
