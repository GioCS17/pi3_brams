#!/usr/bin/env bash
#
#Argumentos
#$1 Nombre de la Carpeta
#$2 Fecha en Formato (20190205)

destinyFolder=`bash download_cptec.sh $1 $2`
#echo $destinyFolder
bash convert_grib2dp.sh $destinyFolder
if [[ -z "${BRAMS_PATH}" ]]; then
  echo "ERROR!: Debes definir el PATH del programa brams como variable de ambiente"
  exit
fi
rutaDeLosDP=$destinyFolder/dp
cp RAMSIN $destinyFolder/RAMSIN
cd $destinyFolder
sed -i "s@RUTADELOSDP@$rutaDeLosDP@g" $destinyFolder/RAMSIN
sed -i "s@./datain@$BRAMS_PATH/datain@g" $destinyFolder/RAMSIN
sed -i "s@./dataout@$BRAMS_PATH/dataout@g" $destinyFolder/RAMSIN
sed -i "s@./shared_datain@$BRAMS_PATH/shared_datain@g" $destinyFolder/RAMSIN
sed -i "s@./tables@$BRAMS_PATH/tables@g" $destinyFolder/RAMSIN

if [ ! -d $BRAMS_PATH/tmp ]; then
	mkdir $BRAMS_PATH/tmp
fi
if [[ -z "${TMPDIR}" ]]; then
  export TMPDIR=$BRAMS_PATH/tmp
fi

$BRAMS_PATH/brams-5.3 -np 4