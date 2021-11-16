#!/usr/bin/env bash
#
# Build the Singularity container
set -ue

if [ ! -z "${DEBUG-}" ]; then
  # make sure it doesn't fail
  git status -s &>/dev/null
  if [ ! "$(git status -s | wc -l)" = "0" ]; then
    echo "Working dir dirty!" >&2
    exit 1
  fi 
fi

sgb(){
  singularity build -F \
    -B "$PWD/vca:/var/cache/apt" \
    -B "$PWD/vla:/var/lib/apt" \
    "$1" "$2" # Recipe and output SIF file
}
if [ ! -f debian-baseimage.sif ]; then 
  singularity build -F debian-baseimage.sif Singularity-baseimage
fi
sgb r-py.sif Singularity-r
sgb rstudio.sif Singularity-rstudio
