#!/usr/bin/env bash
set -ue

export IMG="r-py.sif"
echo "Using Singularity image: ${IMG}"

#
################# Verify R version (label)
#
version () {
  singularity inspect "${IMG}" | \
    grep "R_Version" | \
    awk '{print $2}'
}


singularity exec "$IMG" R -q -e "stopifnot(getRversion() == '$(version)')"



WD="$PWD"
set -x

#
################ Test container setup
#
cd "$WD"
mkdir test 
mkdir test/container-r

cd test/container-r
cp -L ../../r-py.sif .
singularity run r-py.sif setup

#
################ Test project creation
#
cd ..
mkdir project-r
cd project-r
../container-r/createproject --yes

#
################ Test cexec working dir
#
wd="$(./cexec pwd)"
test "$wd" = "/proj"

mkdir subdir
cd subdir
wd="$(../cexec pwd)"
test "$wd" = "/proj/subdir"


#
################ RStudio: setup
#
cd "$WD"
mkdir test/container-rstudio
cd test/container-rstudio
cp -L ../../rstudio.sif .
singularity run rstudio.sif setup

#
################ RStudio: project creation
#
cd ..
mkdir project-rstudio
cd project-rstudio
../container-rstudio/createproject --yes

#
################ RStudio: cexec working dir
#
wd="$(./rstudio exec pwd)"
test "$wd" = "/proj"

mkdir subdir
cd subdir
wd="$(../rstudio exec pwd)"
test "$wd" = "/proj/subdir"

echo "All tests passed!"
