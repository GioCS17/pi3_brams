#This script save the GFS Files on Disk to be converted by GeraDP
#!/usr/bin/env bash

#Step 3: Download the GFS files to convert them to DP (If the DP's don’t exist)

#Arguments
#$1 Name Folder
#$2 Forecast Hours - Hours to be downloaded (072) - 72 Hours
#$3 Formatted Date - i.e. (20190205)

CarpetaDatos=$1 #Carpeta Donde se guardan los datos
incomingDate=$2
FCST=$3

#Variables de Año,Mes,Dia
[[ -z $3 ]] && incomingDate = `date +%Y%m%d`
DiaFolder=`date --date=$incomingDate +%d`
Dia=`date --date=$incomingDate +%Y%m%d`
echo "Saving $FCST Hours from $Dia ..."
#Descarga de Datos
#Directorio Web Donde se Descargan los Datos
#https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.20190708/00/

webAddress="https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs."
dayWebFolder=$webFTPAddressPrefix$Dia/
for i in `seq 0 $FCST`
do
    hourPad=`printf %03d $i`
    link="gfs.t00z.pgrb2.0p25.f$hourPad"
    wget -nc -P $CarpetaDatos $webAddress$Dia/00/$link.idx
    wget -nc -P $CarpetaDatos $webAddress$Dia/00/$link
done