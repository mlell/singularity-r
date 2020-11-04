BootStrap: docker
From: debian:sid

%labels
  Maintainer Moritz Lell
  R_Version 4.0.2

%environment
  export OMP_NUM_THREADS=1

%apprun R
  exec R "${@}"

%apprun Rscript
  exec Rscript "${@}"

%runscript
  exec R "${@}"

%post
  # Software versions
  export R_VERSION=4.0.3

  # Get dependencies
  apt-get update
  apt-get install -y --no-install-recommends \
    locales curl gpg dirmngr gpg-agent libopenblas-dev

  # Configure default locale
  echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
  locale-gen en_US.utf8
  /usr/sbin/update-locale LANG=en_US.UTF-8
  export LC_ALL=en_US.UTF-8
  export LANG=en_US.UTF-8

  # Install R
  apt-get update
  # Installed packages:
  # * R
  # * Python + libpython headers for package compilation
  # * Library headers inspired by CRAN SystemRequirements fields:
  #   - for tidyverse:          libcairo, libxml
  #   - Linear algebra:
  #      libarmadillo
  #   - handle netCDF and HDF files (CRAN: netcdf4, sf, gdal,...)
  #      libnetcdf, libgdal, libproj, libudunits2
  #   - Other geo stuff:
  #      libgeotiff
  #   - Fast Fourier Transform: libfftw
  #   - image manipulation
  #       libtiff5 libjpeg (Pseudo-package ->libjpeg-turbo)
  #       librsvg
  #       imagemagick 
  #   - Glyph rendering and Unicode:
  #       harfbuzz libicu 
  #   - Compression:            zlib1g bzip zstd zip
  #   - Systems Biology ML:     libsbml5
  #   - GNU Scientific Library: gsl
  #   - Cryptography:           libsodium
  #   - BUGS Monte Carlo language: jags
  #   - Linear Programming:     glpk
  #   - CDO Climate data library libcdi
  #   - Grid computing scheduler:
  #       libzmq3 libopenmpi
  #   - libboost-dev -> >100MB! currently not included. -> BH package?
  #   - DBMS:                   libpq (libmariaclientdb <-version mismatch during install)
  apt-get install -y --no-install-recommends \
    r-base=${R_VERSION}* \
    r-base-core=${R_VERSION}* \
    r-base-dev=${R_VERSION}* \
    r-recommended=${R_VERSION}* \
    r-base-html=${R_VERSION}* \
    r-doc-html=${R_VERSION}* \
    libpython3-all-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    vim emacs   nano   graphviz \
    git procps  pandoc imagemagick \
    jags \
    libxml2-dev \
    libcairo2-dev \
    libxt-dev \
    libarmadillo-dev \
    libnetcdf18 libnetcdf-dev libhdf5-dev\
    gdal-bin libgdal-dev \
    proj-bin libproj-dev \
    libudunits2-dev \
    libgeotiff-dev \
    libfftw3-dev \
    libtiff-dev libjpeg-dev librsvg2-dev libpng-dev \
    libharfbuzz-dev libicu-dev\
    zlib1g-dev libbz2-dev libzstd-dev libzip-dev\
    libsbml5-dev \
    libgsl-dev \
    libsodium-dev \
    libglpk-dev \
    libcdi-dev \
    libzmq3-dev libopenmpi-dev libcoarrays-openmpi-dev \
    libpq-dev 
#libmariadbclient-dev 
    
    
    
    

  # Add a default CRAN mirror
  echo "options(repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'libcurl')" >> /usr/lib/R/etc/Rprofile.site
  
  # Set default python version
  ln -s python3 /usr/bin/python

  # Clean up
  rm -rf /var/lib/apt/lists/*

