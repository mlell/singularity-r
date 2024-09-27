# Singularity R

[![GitHub License](https://img.shields.io/badge/license-MIT-green.svg)](https://opensource.org/licenses/MIT)

Singularity images for R, Python 3 and RStudio Server.

These images can be used to improve reproducibility in producing analyses with
R and Python. 

## Downloading the container

**Option 1:** If you trust me, download the latest archive from the 
["Releases"](https://github.com/mlell/singularity-r/releases) section.

Extract the downloaded archive. **Note:** In the following, the extracted
directory is referred to as *CONTAINER_DIR*. Replace that with the real 
folder for your case when executing commands shown here!

**Option 2:** (You need to have root rights for this) Clone this repository
and execute `sudo ./build.sh`. This calls `singularity build` to produce
two versions of the container, with and without RStudio Server. If you change
anything, the build will abort because the current git commit is saved in the
SIF file. To build from a dirty working directory, use `sudo DEBUG=TRUE ./build`.
Maybe it will complain that it is missing a GPG key for checking the signature
on the downloaded packages. Load those using 
`gpg --keyserver keyserver.ubuntu.com --recv-key <key-id>`

## How to use

To start RStudio, first to to your analysis project using `cd` and then execute
`CONTAINER_DIR/createproject-rstudio`. You must do this only once. This will 
generate a file called `rstudio` in your folder. Execute `./rstudio start`.

To run a program of the container, like `Rscript` for an R computation without
starting RStudio, execute `./rstudio exec -i exec PROGRAM ARGS...`. (Replace
all-caps parts)

For more information, use the help pages like `./rstudio --help`, 
`./rstudio start --help`, `./rstudio exec --help`, etc.

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
dependencies of your work. Open the file `./rstudio` that you have created
using `creatproject-rstudio` and see the section about `EXTERNAL_FILES`. 
However, note that any external dependency will make your results more
complicated to reproduce by others and yourself in the future.


## Build Reproducibility

The container uses [snapshot.debian.org](https://snapshot.debian.org/)
as a mirror, so the software versions should not differ between different builds of
this container, given it is based on the same commit of this repository. The snapshot
timestamp is included in the `MirrorURL:` line of the file `Singularity-r`.

To rebuild the Singularity images with different (e.g. newer) software versions, change
the following places:

 * In `Singularity-baseimage` the timecode in the line starting with "MirrorURL".
   Go to snapshots.debian.org to see which time codes are possible
 * In `Singularity-rstudio` the two lines that mention the RStudio version.

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
