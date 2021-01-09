#!/bin/sh

module load openmpi/2.1.6
module load gcc/7.5.0
module load cmake/3.16.5

mkdir -p brams-5.3
tar -zxvf brams-5.3-src.tgz -C brams-5.3
sed -i 's/STOP\x27init_top\x27/STOP \x27init_top\x27/' brams-5.3/src/jules/LIB/SOURCE/SUBROUTINES/INITIALISATION/init_top.f90
sed -i 's/integer,  dimension (12) :: seed/integer,  dimension (33) :: seed/' brams-5.3/src/brams/cuparm/module_cu_g3.f90
cd brams-5.3/build

./configure -program-prefix=BRAMS \
-prefix=/home/leonidas.garcia/brams-5.3/brams -enable-jules \
-with-chem=RELACS_TUV -with-aer=SIMPLE \
-with-fpcomp=/opt/apps/openmpi-2.1.6/bin/mpif90 \
-with-cpcomp=/opt/apps/openmpi-2.1.6/bin/mpicc \
-with-fcomp=/opt/apps/gcc-7.5.0/bin/gfortran \
-with-ccomp=/opt/apps/gcc-7.5.0/bin/gcc
make && make install

module unload openmpi/2.1.6
module unload gcc/7.5.0
module unload cmake/3.16.5
