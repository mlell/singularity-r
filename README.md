# Singularity R

[![GitHub License](https://img.shields.io/badge/license-MIT-green.svg)](https://opensource.org/licenses/MIT)

Singularity images for R, Python 3 and RStudio Server.

These images can be used to improve reproducibility in producing analyses with R and
Python. 

## Reproducible file paths

The containers are accompanied by helper scripts that make your project available at
the path `/proj`, regardless of where the files lie on your machine. This way, using
absolute paths does not lead to reproducibility issues. So, if you create your analyis,
be sure to refer to a file with a path starting with

    /proj/PATH/TO/YOUR/FILE

The directory `/proj` will be translated to your project root directory. The section 
"How to obtain" describes how to set your project root directory.

A possibility to include external files and folders is also available which enables
to clearly document the dependencies of your work. It is also described in the next
section.

## How to obtain

**Option 1:** If you trust me, download the image from the 
["Releases"](https://github.com/mlell/singularity-r/releases) section. The 
commit on which the image is based is included as a container label.

**Option 2:** Clone this repository and execute `sudo ./build.sh`. This calls 
`singularity build` to produce two versions of the container, with and without
RStudio Server. 

## Run

1. Download one of the container image into its own directory. Do not rename the 
   containers from their original names `r-py.sif` or `rstudio.sif`, or you will
   have to adapt the helper scripts.
2. Change working directory to the container folder and execute 
  
       singularity run -B "$PWD" --pwd "$PWD" CONTAINERNAME.sif setup
       
   This will copy several helper scripts to the same directory as the container.
   Once this is done, you can run several different projects using the same 
   container.
3. Change the working directory to the main folder of the analysis. Run

       /PATH/TO/CONTAINER/createproject

   This will copy a script into your project directory that contains the link to
   the used container and enables you to define external files and folders that
   shall be provided to the apps inside the container. 

   Instead of an absolute path, you can also provide a relative path, for 
   example if you place the container in a subfolder of your project.
4. To start RStudio Server, change to your project directory and run the script

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
