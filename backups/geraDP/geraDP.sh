#! /bin/bash
#
# ==============================================================================
# geraDP
# ==============================================================================
#
# This script is part of geraDP program, it must be used to call geraDP program.
# It generates the dp's files for BRAMS using GFS files as input.
#
# geraDP.sh, geraDP.gs, geraDP.x and geraDP.ini files must be in the same directory.
#
# Please refer to documentation for details.
#
#
# Revisions / authors:
# ====================
# 2003-05-02 - Demerval S. Moreira (demervalsm@gmail.com) 02/Mai/2003 - Initial version
#
# 2018-11-12 - Denis Eiras (denis.eiras@inpe.br) = geraDP.ini included for geraDP configuration.
#
#
# Running:
# ========
#
# 1) Configure parameter in geraDP.ini (mainly section "Parameters frequently changed")
# 2) run ./geraDP.sh
#

grads=grads
DIR_fonte=`dirname $0`
DIR_dp=`pwd`
clear
echo "The DP files will be generated in the current working directory: "`pwd`

# Parameters:
# ===========
source geraDP.ini
nome=$ctl_file_name
u=$wind_u_varname
v=$wind_v_varname
temp=$temperature_varname
geo=$geo_varname
ur=$ur_varname
zmax=$z_max_level
lat2i=$initial_latitude
lat2f=$final_latitude
lon2i=$initial_longitude
lon2f=$final_longitude
to_f90=$binary_grads_exists

echo; echo "The following ctl files was found in this dir:"; echo
if [ x$nome = "x" ]
then
  ls -1 *.ctl *.nc
  echo;echo -n "Enter the CTL filename or .nc (ex: /home/user/avn/avn.ctl)=> "
  read nome
  echo;echo -n 'The binary file is already formated to be read by the fortran program - In doubt, choose "N" (y/N): '
  read to_f90
fi

nc=$(echo $nome | awk -F "." '{print $NF}')

if [ $nc != 'nc' ]; then
   nX=`grep -i xdef $nome | awk '{print $2}'`
   loni=`grep -i xdef $nome | awk '{print $4}'`
   intX=`grep -i xdef $nome | awk '{print $5}'`
   nY=`grep -i ydef $nome | awk '{print $2}'`
   lati=`grep -i ydef $nome | awk '{print $4}'`
   intY=`grep -i ydef $nome | awk '{print $5}'`
   nlev=`grep -i zdef $nome | awk '{print $2}'`
   nt=`grep -i tdef $nome | awk '{print $2}'`
   indef=`grep -i UNDEF $nome | awk '{print $2}'`
   linear=`grep -i ydef $nome | awk '{print substr($3,2,1)}'`
   linearx=`grep -i xdef $nome | awk '{print substr($3,2,1)}'`
else
   grads -clb "sdfopen $nome" << EOF
     q ctlinfo
     quit
EOF
   echo
   echo "Please type the information above to the parameters:"
   echo -n "indef (undefined value): "
   read indef
   echo -n "nX (X number of points): "
   read nX
   echo -n "loni (initial longitude): "
   read loni
   echo -n "intX (delta X): "
   read intX
   echo -n "nY (Y number of points): "
   read nY
   echo -n "lati (initial latitude): "
   read lati
   echo -n "intY (delta Y): "
   read intY
   echo -n "nlev (levels): "
   read nlev
   echo -n "nt (time levels): "
   read nt
   linear='i'
   linearx='i'
fi

if [ $linear = 'e' -o $linear = 'E' -o  $linearx = 'e' -o $linearx = 'E' ];then
  echo;echo "X or Y spacing is not linear, use a type of regrid to convert the grid to linear.Quiting..."
  exit
fi

cd $DIR_dp
if test -s $DIR_dp/dims.txt; then rm -f $DIR_dp/dims.txt; fi

grads_parameters="run $DIR_fonte/geraBIN.gs $nome $nX $loni $intX $nY $lati $intY $nlev $nt $indef $linear $to_f90 $nc $u $v $temp $geo $ur $zmax $lat2i $lat2f $lon2i $lon2f $wind_u_z_limit $wind_u_default_value $wind_v_z_limit $wind_v_default_value $temp_z_limit $temp_default_value $geo_z_limit $geo_default_value $ur_z_limit $ur_default_value"

if [ x$to_f90 = "xY" -o x$to_f90 = "xy" ]; then
    Nbin=`grep -i dset $nome | awk '{print $2}'`
    tem=`echo $Nbin | grep "\^" | wc -l`
    if [ $tem -eq 1 ];then Nbin=`dirname $nome`/`echo $Nbin | sed s%"\^"%%g`; fi
    if test ! -s $Nbin; then echo;echo "The binary file was not found: $Nbin    Quiting...";exit;fi
    echo $Nbin
    $grads -clb "$grads_parameters"

else
    echo "------------- Generating the binary file to be read by the fortran program ---------------------"
    $grads -clb "$grads_parameters"
    echo "------------- Binary file generated ---------------------"
    Nbin=$DIR_dp/'to_dp.gra'
fi

tam=`ls -l $Nbin | awk '{print $5}'`

echo "------------- Generating the DP files ---------------------"
$DIR_fonte/geraDP.x $Nbin $tam $DIR_dp'/'
rm -f $DIR_dp/dims.txt
if [ x$to_f90 = "xS" -o x$to_f90 = "xs" ]; then
	echo "Keeping the file $Nbin"
else
	echo "Removing the file $Nbin"
    rm -f $Nbin
fi

exit

