#
# Makefile to compile the programs grbconv e grib2dp
#
# Those programs will convert a grib file to a RALPH2 dp file
# to use in BRAMS.
#
# To compile it, modify the following variables to meet your system
#
# FORTRAN 90 compiler
FC=gfortran
#
# C Compiler
CC=gcc
# 
# Instructions to use it is located in the README file
#
# By P', PAD / CPTEC
# 
all: grbconv grib2dp

grbconv:
	$(CC) grbconv.c -lm -o grbconv

grib2dp:
	$(FC) grib2dp.f90 -o grib2dp

clean:
	rm -f grbconv grib2dp
