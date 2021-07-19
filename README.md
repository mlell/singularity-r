# Singularity R

[![GitHub License](https://img.shields.io/badge/license-MIT-green.svg)](https://opensource.org/licenses/MIT)

Singularity image for [R].

An R image with several libraries, aimed to help in reproducibly writing research
scripts in the area of breeding research and quantitative genetics.

## Build

You can build a local Singularity image named `singularity-r.simg` with:

```sh
sudo singularity build singularity-r.simg Singularity
```


## Run

### R

The `R` command is launched using the default run command:

```sh
singularity run singularity-r.simg
```

or as an explicit app:

```sh
singularity run --app R singularity-r.simg
```

Example:

```console
$ singularity run --app R singularity-r.simg --version
R version 3.4.3 (2017-11-30) -- "Kite-Eating Tree"
Copyright (C) 2017 The R Foundation for Statistical Computing
Platform: x86_64-pc-linux-gnu (64-bit)

R is free software and comes with ABSOLUTELY NO WARRANTY.
You are welcome to redistribute it under the terms of the
GNU General Public License versions 2 or 3.
For more information about these matters see
http://www.gnu.org/licenses/.
```

### Rscript

The `Rscript` command is launched as an explicit app:

```sh
singularity run --app Rscript singularity-r.simg
```

Example:

```console
$ singularity run --app Rscript singularity-r.simg --version
R scripting front-end version 3.4.3 (2017-11-30)
```

## Contents

The container is based on Debian Sid (unstable). Installed programs
and libraries: 

  * R
  * Python + libpython headers for package compilation
  * Library headers inspired by CRAN SystemRequirements fields:
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
     - DBMS:                   libpq 

## License

The code is available as open source under the terms of the [MIT License].

[R]: https://www.r-project.org/
[MIT License]: http://opensource.org/licenses/MIT
