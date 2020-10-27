#!/bin/sh

# Based on http://cola.gmu.edu/grads/gadoc/supplibs2.html
# 26-10-2020

ROOT_PATH=$HOME
GRADS="${ROOT_PATH}/grads"
SUPPLIBS="${GRADS}/supplibs"

function module_loads {
  echo "Loading modules"
  module load openmpi/2.1.6 
  module load gcc/5.5.0 
  module load cmake/3.16.5 
}

function create_directories {
  echo "Creating directories"
  mkdir -p $GRADS
  mkdir -p $GRADS/installed
  mkdir -p $SUPPLIBS
  mkdir -p $SUPPLIBS/tarfiles
  mkdir -p $SUPPLIBS/src
  mkdir -p $SUPPLIBS/lib
  mkdir -p $SUPPLIBS/include
  mkdir -p $SUPPLIBS/bin
}

function install_readline {
  echo "Installing readline"
  wget -nc -P $SUPPLIBS/tarfiles ftp://ftp.cwru.edu/pub/bash/readline-5.0.tar.gz
  cd $SUPPLIBS/src
  tar xvfz $SUPPLIBS/tarfiles/readline-5.0.tar.gz
  cd readline-5.0
  ./configure --prefix=$SUPPLIBS
  make install
}

function install_ncurses {
  echo "Installing ncurses"
  wget -nc -P $SUPPLIBS/tarfiles ftp://ftp.invisible-island.net/ncurses/ncurses-5.7.tar.gz
  cd $SUPPLIBS/src
  tar xvfz $SUPPLIBS/tarfiles/ncurses-5.7.tar.gz
  cd ncurses-5.7
  ./configure --prefix=$SUPPLIBS --without-ada --with-shared
  make install
}

function install_zlib {
  echo "Installing zlib"
  wget -nc -P $SUPPLIBS/tarfiles http://ftp.osuosl.org/pub/clfs/conglomeration/zlib/zlib-1.2.8.tar.gz
  cd $SUPPLIBS/src
  tar xvfz $SUPPLIBS/tarfiles/zlib-1.2.8.tar.gz
  cd zlib-1.2.8
  ./configure --prefix=$SUPPLIBS
  make install
}

function install_libpng {
  echo "Installing libpng"
  wget -nc -P $SUPPLIBS/tarfiles https://ftp-osl.osuosl.org/pub/libpng/src/libpng15/libpng-1.5.30.tar.gz
  cd $SUPPLIBS/src
  tar xvfz $SUPPLIBS/tarfiles/libpng-1.5.30.tar.gz
  cd libpng-1.5.30
  ./configure --prefix=$SUPPLIBS
  make install
}

function install_jpeg {
  echo "Installing jpeg"
  wget -nc -P $SUPPLIBS/tarfiles https://ijg.org/files/jpegsrc.v6b.tar.gz
  cd $SUPPLIBS/src
  tar xvfz $SUPPLIBS/tarfiles/jpegsrc.v6b.tar.gz
  cd jpeg-6b
  ./configure --prefix=$SUPPLIBS
  make
  cp libjpeg.a $SUPPLIBS/lib
  cp *.h $SUPPLIBS/include
}

function install_gd {
  echo "Installing gd"
  wget -nc -P $SUPPLIBS/tarfiles https://github.com/libgd/libgd/releases/download/gd-2.2.5/libgd-2.2.5.tar.gz
  cd $SUPPLIBS/src
  tar xvfz $SUPPLIBS/tarfiles/libgd-2.2.5.tar.gz
  cd libgd-2.2.5
  ./configure --prefix=$SUPPLIBS --with-png=$SUPPLIBS --with-jpeg=$SUPPLIBS --disable-shared
  make install
}

function install_jasper {
  echo "Installing jasper"
  wget -nc -P $SUPPLIBS/tarfiles https://www.ece.uvic.ca/~frodo/jasper/software/jasper-1.900.16.tar.gz
  cd $SUPPLIBS/src
  tar xvfz $SUPPLIBS/tarfiles/jasper-1.900.16.tar.gz
  cd jasper-1.900.16
  ./configure --prefix=$SUPPLIBS --with-png=$SUPPLIBS --with-jpeg=$SUPPLIBS
  make install
}

function install_g2clib {
  echo "Installing j2clib"
  wget -nc -P $SUPPLIBS/tarfiles https://www.nco.ncep.noaa.gov/pmb/codes/GRIB2/g2clib-1.6.0.tar
  cd $SUPPLIBS/src
  tar xvf $SUPPLIBS/tarfiles/g2clib-1.6.0.tar
  cd g2clib-1.6.0
  SED_SUPPLIBS=${SUPPLIBS////\\/}
  sed -i "20s/.*/INC=-I$SED_SUPPLIBS\/include -I$SED_SUPPLIBS\/include\/libpng15\//" makefile
  sed -i "28s/.*/CFLAGS= -O3 -g -m64 \$(INC) \$(DEFS) -D__64BIT__ -fPIC/" makefile
  make
  cp -f libg2c_v1.6.0.a $SUPPLIBS/lib/libgrib2c.a
  cp -f grib2.h $SUPPLIBS/include
}

function install_szip {
  echo "Installing szip"
  wget -nc -P $SUPPLIBS/tarfiles https://support.hdfgroup.org/ftp/lib-external/szip/2.1.1/src/szip-2.1.1.tar.gz
  cd $SUPPLIBS/src
  tar xvf $SUPPLIBS/tarfiles/szip-2.1.1.tar.gz
  cd szip-2.1.1/
  ./configure --prefix=$SUPPLIBS
  make
  make install
}

function install_udunits {
  echo "Installing udunits"
  wget -nc -P $SUPPLIBS/tarfiles https://www.unidata.ucar.edu/downloads/udunits/udunits-2.2.25.tar.gz
  cd $SUPPLIBS/src
  tar xvfz $SUPPLIBS/tarfiles/udunits-2.2.25.tar.gz
  cd udunits-2.2.25
  ./configure --prefix=$SUPPLIBS --disable-shared
  make
  make install
}

function install_hdf4 {
  echo "Installing hdf4"
  wget -nc -P $SUPPLIBS/tarfiles https://support.hdfgroup.org/ftp/HDF/releases/HDF4.2.15/src/CMake-hdf-4.2.15.tar.gz
  cd $SUPPLIBS/src
  tar xvfz $SUPPLIBS/tarfiles/CMake-hdf-4.2.15.tar.gz
  cd CMake-hdf-4.2.15/
  cmake -D CMAKE_INSTALL_PREFIX=$SUPPLIBS hdf-4.2.15/
  make
  make install
}

function install_hdf5 {
  echo "Installing hdf5"
  wget -nc -P $SUPPLIBS/tarfiles https://hdf-wordpress-1.s3.amazonaws.com/wp-content/uploads/manual/HDF5/HDF5_1_10_7/src/CMake-hdf5-1.10.7.tar.gz
  cd $SUPPLIBS/src
  tar xvfz $SUPPLIBS/tarfiles/CMake-hdf5-1.10.7.tar.gz
  cd CMake-hdf5-1.10.7/
  cmake -D CMAKE_INSTALL_PREFIX=$SUPPLIBS/ hdf5-1.10.7/
  make
  make install
}

function install_curl {
  echo "Installing curl"
  wget -nc -P $SUPPLIBS/tarfiles https://curl.haxx.se/download/curl-7.67.0.tar.gz
  cd $SUPPLIBS/src
  tar -xvf $SUPPLIBS/tarfiles/curl-7.67.0.tar.gz
  cd curl-7.67.0/
  ./configure --prefix=$SUPPLIBS
  make
  make install
}

function install_netcdf {
  echo "Installing netcdf"
  wget -nc -P $SUPPLIBS/tarfiles https://github.com/Unidata/netcdf-c/archive/v4.7.3.tar.gz
  cd $SUPPLIBS/src
  tar -xvf $SUPPLIBS/tarfiles/v4.7.3.tar.gz
  cd netcdf-c-4.7.3/
  mkdir build
  cd build
  cmake ../ -DCMAKE_INSTALL_PREFIX=$SUPPLIBS -DCMAKE_FIND_ROOT_PATH=$SUPPLIBS/
  make
  make install
}

function install_tiff {
  echo "Installing diff"
  wget -nc -P $SUPPLIBS/tarfiles https://download.osgeo.org/libtiff/old/tiff-3.8.2.tar.gz
  cd $SUPPLIBS/src
  tar xvfz $SUPPLIBS/tarfiles/tiff-3.8.2.tar.gz
  cd tiff-3.8.2
  ./configure --prefix=$SUPPLIBS
  make install
}

function install_geotiff {
  echo "Installing geotiff"
  wget -nc -P $SUPPLIBS/tarfiles http://download.osgeo.org/geotiff/libgeotiff/libgeotiff-1.2.5.tar.gz
  cd $SUPPLIBS/src
  tar xvzf $SUPPLIBS/tarfiles/libgeotiff-1.2.5.tar.gz
  cd libgeotiff-1.2.5
  ./configure --prefix=$SUPPLIBS --enable-incode-epsg --enable-static --with-libtiff=$SUPPLIBS
  make
  make install
}

function install_shapelib {
  echo "Installing shapelib"
  wget -nc -P $SUPPLIBS/tarfiles http://download.osgeo.org/shapelib/shapelib-1.2.10.tar.gz
  cd $SUPPLIBS/src
  tar xvfz $SUPPLIBS/tarfiles/shapelib-1.2.10.tar.gz
  cd shapelib-1.2.10
  sed -i "3s/.*/CFLAGS = -g -fPIC/" Makefile
  sed -i 's/-g -O2/-g -fPIC -O2/g' Makefile
  make all lib
  cp -f .libs/libshp.a $SUPPLIBS/lib
  cp -f shapefil.h $SUPPLIBS/include
  cp -f shpcreate shpadd shpdump shprewind dbfcreate dbfadd dbfdump shptest $SUPPLIBS/bin
}

function install_xml2 {
  echo "Installing xml2"
  wget -nc -P $SUPPLIBS/tarfiles http://xmlsoft.org/sources/libxml2-2.9.0.tar.gz
  cd $SUPPLIBS/src
  tar xvfz $SUPPLIBS/tarfiles/libxml2-2.9.0.tar.gz
  cd libxml2-2.9.0
  ./configure --prefix=$SUPPLIBS --with-zlib=$SUPPLIBS --without-threads --without-iconv --without-iso8859x --without-lzma
  make install
}

function install_xrender {
  echo "Installing xrender"
  wget -nc -P $SUPPLIBS/tarfiles ftp://cola.gmu.edu/grads/Supplibs/2.2/src/libXrender-0.9.6.tar.gz
  cd $SUPPLIBS/src
  tar xvfz $SUPPLIBS/tarfiles/libXrender-0.9.6.tar.gz
  cd libXrender-0.9.6/
  ./configure --prefix=$SUPPLIBS
  make install
}

# TODO: ERROR
function install_pkgconfig {
  echo "Installing pkgconfig"
  wget -nc -P $SUPPLIBS/tarfiles ftp://cola.gmu.edu/grads/Supplibs/2.2/src/pkgconfig-0.23.tar.gz
  cd $SUPPLIBS/src
  tar xvfz $SUPPLIBS/tarfiles/pkg-config-0.23.tar.gz
  cd pkg-config-0.23
  ./configure --prefix=$SUPPLIBS
  make install
  export PKG_CONFIG=$SUPPLIBS/bin/pkg-config
  export PKG_CONFIG_PATH=$SUPPLIBS/lib/pkgconfig
}

function install_libdap {
  echo "Installing libdap"
  wget -nc -P $SUPPLIBS/tarfiles https://www.opendap.org/pub/source/libdap-3.18.1.tar.gz
  cd $SUPPLIBS/src
  tar xvfz $SUPPLIBS/tarfiles/libdap-3.18.1.tar.gz
  cd libdap-3.18.1/
  export CPPFLAGS=-I${SUPPLIBS}/include
  ./configure --prefix=$SUPPLIBS --with-curl=$SUPPLIBS
  make install
}

# TODO: Fixing
function install_gapad {
  echo "Installing gadap"
  wget -nc -P $SUPPLIBS/tarfiles ftp://cola.gmu.edu/grads/Supplibs/2.2/src/gadap-2.1.tar.gz
  cd $SUPPLIBS/src
  tar xvfz $SUPPLIBS/tarfiles/gadap-2.1.tar.gz
  cd gadap-2.1
  export PATH=$SUPPLIBS/bin:$PATH
  export CPPFLAGS=-I${SUPPLIBS}/include
  ./configure --prefix=$SUPPLIBS
  make install
}

# TODO: Missing
function install_pixman {
  echo "Installing pixman"
}

# TODO: Missing
function install_freetype {
  echo "Installing freetype"
}

# TODO: Missing
function install_fontconfig {
  echo "Installing fontconfig"
}

# TODO: Missing
function install_cairo {
  echo "Installing cairo"
}

function install_grads {
  echo "Installing grads"
  wget -nc -P $SUPPLIBS/tarfiles ftp://cola.gmu.edu/grads/2.0/grads-2.0.2-src.tar.gz
  cd $SUPPLIBS/src
  tar xvfz $SUPPLIBS/tarfiles/grads-2.0.2-src.tar.gz
  cd grads-2.0.2
  ./configure --prefix=$GRADS/installed \
  SUPPLIBS=$SUPPLIBS --disable-dyn-supplibs \
  CFGLAGS=-I$SUPPLIBS/include \
  LDFLAGS=-L$SUPPLIBS/lib
  make
  make install
}

function module_unloads {
  echo "Unloading modules"
  module unload openmpi/2.1.6 
  module unload gcc/5.5.0 
  module unload cmake/3.16.5 
}

module_loads
create_directories
#install_readline
#install_ncurses
#install_zlib
#install_libpng
#install_jpeg
#install_gd
#install_jasper
#install_g2clib
#install_szip
#install_udunits
#install_hdf4
#install_hdf5
#install_curl
#install_netcdf
#install_tiff
#install_geotiff
#install_shapelib
#install_xml2
#install_xrender
#install_pkgconfig
#install_libdap
#install_gapad
#install_pixman #TODO
#install_freetype #TODO
#install_fontconfig #TODO
#install_cairo #TODO
install_grads
module_unloads

