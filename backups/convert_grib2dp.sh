#!/usr/bin/env bash

#Argumentos
#$1 Nombre de la Carpeta Donde Estan los grb (/home/goldensniper/DATABRAMS/2019/02/05)

if [[ -z "${GRIB2DP_PATH}" ]]; then
  echo "ERROR!: Debes definir el PATH del programa grib2dp como variable de ambiente"
  exit
fi

fileRegex=$1/GAMRAMS*TQ0126L028.grb
cp PREP_IN $1/PREP_IN

sed -i "s@ESTOVAACAMBIARSE@$fileRegex@g" $1/PREP_IN
$GRIB2DP_PATH/grib2dp $1/PREP_IN

#sed -i "s@$fileRegex@ESTOVAACAMBIARSE@g" PREP_IN