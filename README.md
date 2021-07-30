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

**Option 1:** If you trust me, download the image from the "Releases" section. The 
commit on which the image is based is included as a container label.

**Option 2:** Clone this repository and execute `sudo ./build.sh`. This calls 
`singularity build` to produce two versions of the container, with and without
RStudio Server. 

## Run

1. Download one of the container image into its own directory. Do not rename the 
   containers from their original names `r-py.sif` or `rstudio.sif`, or you will
   have to adapt the helper scripts.
2. Execute `singularity run r-py.sif setup` or `singularity run rstudio.sif setup`.
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

## License

The code is available as open source under the terms of the [MIT License].

[MIT License]: http://opensource.org/licenses/MIT
