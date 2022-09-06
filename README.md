# Singularity R

[![GitHub License](https://img.shields.io/badge/license-MIT-green.svg)](https://opensource.org/licenses/MIT)

Singularity images for R, Python 3 and RStudio Server.

These images can be used to improve reproducibility in producing analyses with
R and Python. 

## What is a project folder

This projects works with the idea of a **project folder**. That is a folder
that you want to be a self-contained analysis, so all the files needed for the
analysis are in that folder. When the container is started, you will see the 
files of the project folder under the the path `/proj`. Files outside of the 
project folder will not be visible from inside the container! 

This way, using absolute paths does not lead to reproducibility issues.
Regardless on where the project folder lies on your computer, from inside it
will always be found in the folder `/proj`. So, if you move your analysis to
another computer, it can still be run without changing file paths in the
analysis.

A possibility to include files and folders that are outside of the project 
folder is also available which enables you to clearly document additional 
dependencies of your work.

## Downloading the container

**Option 1:** If you trust me, download the latest archive from the 
["Releases"](https://github.com/mlell/singularity-r/releases) section.

Extract the downloaded archive. **Note:** In the following, the extracted
directory is referred to as *CONTAINER_DIR*. Replace that with the real 
folder for your case when executing commands shown here!

**Option 2:** (You need to have root rights for this) Clone this repository
and execute `sudo ./build.sh`. This calls `singularity build` to produce
two versions of the container, with and without RStudio Server. 

## Connecting your project to the container

These steps must be done once for each project. 

Change the working directory to your *project folder*. That is the directory
that holds the files of your analysis. Only files in this folder and subfolders
will be visible from RStudio! This ensures that you have everything which is 
needed for your analysis in one folder.

    cd PROJECT_DIR    # <-- replace by your project directory!

Then create the starter script in the project folder (you have to replace
`CONTAINER_DIR` to the location where you downloaded and extracted the 
container!):

    CONTAINER_DIR/createproject

This will copy a script called `rstudio` into your project directory that can
start the container. It also contains settings like external files and folders
that shall be provided to the apps inside the container. 
 
## Starting RStudio Server 

Change to your project directory and run the script

       ./rstudio start
 
There are several other functions. List them using `./rstudio --help`

To run other programs from within the container, if you use `rstudio.sif`, run
 
    ./rstudio exec COMMAND ARGS....

or if you use `r-py.sif`, run

    ./cexec COMMAND ARGS...



## Build Reproducibility

The container uses [snapshot.debian.org](https://snapshot.debian.org/)
as a mirror, so the software versions should not differ between different builds of
this container, given it is based on the same commit of this repository. The snapshot
timestamp is included in the `MirrorURL:` line of the file `Singularity-r`.


## Contents

The container is based on Debian Sid (unstable). Installed programs
and libraries: 

  * R
  * Python + libpython headers for package compilation
  * vim, emacs-nox, imagemagick, git 
  * Library headers inspired by CRAN SystemRequirements fields:
     - C++ Boost
       * [Pseudo-package as a replacement](https://packages.debian.org/de/sid/r-cran-bh)
         for the R "BH" package to avoid reinstallation of Boost by R's `install.packages()`
         function.
     - for tidyverse: libcairo, libxml
     - linear algebra: libarmadillo
     - netCDF and HDF files (CRAN packages: netcdf4, sf, gdal,...)
        - libnetcdf
        - libgdal
        - libproj
        - libudunits2
     - Other geo stuff: libgeotiff
     - Fast Fourier Transform: libfftw
     - image manipulation
         - libtiff5
         - libjpeg
         - librsvg
         - imagemagick 
     - Glyph rendering and Unicode:
         - harfbuzz
         - libicu 
     - Compression:
         - zlib1g
         - bzip
         - zstd
         - zip
     - Systems Biology ML:     libsbml5
     - GNU Scientific Library: gsl
     - Cryptography:           libsodium
     - BUGS Monte Carlo language: jags
     - Linear Programming:     glpk
     - CDO Climate data library: libcdi
     - Grid computing scheduler:
         - libzmq3
         - libopenmpi
     - PostgreSQL:              libpq 

## OpenBLAS

OpenBLAS provides large speedups and parallel computation of linear algebra 
operations. This package does not include the OpenBLAS libraries, as we have
experienced problems when doing calculations on older machines (Skylake CPUs,
[OpenBLAS#3454](https://github.com/xianyi/OpenBLAS/issues/3454)). You can add 
the OpenBLAS libraries yourself by binding them into the container, masking
the BLAS libraries in the container. 

**Step 1:** Follow the steps in section "Run" (except the final step 4, which
is not nessecary for this)

**Step 2:** Download and compile an OpenBLAS version. Here, we download OpenBLAS
into a folder directly in your project directory that is available as `/proj`
inside the container. Other folders are also possible, but we recommend you
put it somewhere inside the project directory or the container directory.

```sh
# Download an openblas version
git clone -b v0.3.18 https://github.com/xianyi/OpenBLAS
cd OpenBLAS
# enter a shell inside the container. For the RStudio container, replace
# "cexec" by "rstudio"
../cexec exec bash 
make
# PREFIX is the install path, it must be specific for each machine. 
# Other than that, you can choose it freely
make install PREFIX="inst/$(hostname)" 
```

You can also try to call "make TARGET=GENERIC" so that you do not need
a special version for each machine you run on. But that might slow down
you later calculations. You will have to test the effect yourself. This
is how you would do it.

```sh
make TARGET=GENERIC
make install PREFIX=inst   # PREFIX is the install path, you can choose
```

**Step 3:** Add to the `EXTERNAL_FILES` variable in the `cexec` or `rstudio`
script, respectively, to add the OpenBLAS libraries inside the container:

```sh
# After the EXTERNAL_FILES variable has been defined
openblaspath="$thisdir/OpenBLAS/inst/$(hostname)"
if [ -d "$openblaspath" ]; then
  EXTERNAL_FILES+=( 
    "$(readlink -f "${openblaspath}/lib/libopenblas.so:/usr/lib/R/lib/libblas.so.3" )
fi
```

(The needed pathof the library inside the container is set by
the file `/usr/lib/R/etc/ldpaths` and environment variable 
`R_LD_LIBRARY_PATH`. The name was derived by running `ldd /usr/lib/R/bin/exec/R`.) 

Note that in this example, the step 2 must be repeated on every host that the
container is used on (except if the approach in the last paragraph of step 2
is followed, but this is not tested). Be sure to test that you get correct
results from OpenBLAS in either case.

## License

The code is available as open source under the terms of the [MIT License].

[MIT License]: http://opensource.org/licenses/MIT
