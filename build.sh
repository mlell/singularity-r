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

# Reuse the apt cache directories across builds. Inside the Singularity
# recipes, do not delete but unmount them after the installation
sgb(){
  singularity build -F \
    -B "$PWD/vca:/var/cache/apt" \
    -B "$PWD/vla:/var/lib/apt" \
    "$1" "$2" # Recipe and output SIF file
}
#if [ ! -f debian-baseimage.sif ]; then 
  # Cannot use sgb() here because we start from scratch, so the mounted directores
  # are not yet there.
  # Do not auto-cleanup, this would remove files in bind-mounted directories
  # The paths must be unmounted first. We have to include it here and not
  # in the sgb() function because here, we bind-mount in the %setup section of
  # the Singularity recipe. Therefore we have to also take care to unmount it
  # by ourselves. In sgb(), Singularity makes sure that bind-mounted directories
  # are not deleted in case of error.
 # singularity build -F --no-cleanup debian-baseimage.sif Singularity-baseimage
#fi

sgb debian-baseimage.sif Singularity-baseimage
sgb r-py.sif Singularity-r
sgb rstudio.sif Singularity-rstudio

